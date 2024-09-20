import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import mongoose from 'mongoose';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import cors from 'cors';
import dotenv from 'dotenv';
import helmet from 'helmet';
import compression from 'compression';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(cors());
app.use(express.json());
app.use(helmet());
app.use(compression());

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const UserSchema = new mongoose.Schema({
  username: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  profilePicture: { type: String, default: '' },
});

const MessageSchema = new mongoose.Schema({
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  content: String,
  timestamp: { type: Date, default: Date.now },
  isGroupMessage: { type: Boolean, default: false },
  groupId: { type: mongoose.Schema.Types.ObjectId, ref: 'Group' },
});

const GroupSchema = new mongoose.Schema({
  name: { type: String, required: true },
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  admins: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
});

const User = mongoose.model('User', UserSchema);
const Message = mongoose.model('Message', MessageSchema);
const Group = mongoose.model('Group', GroupSchema);

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (token == null) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'content/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

app.post('/register', async (req, res) => {
  try {
    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    const user = new User({
      username: req.body.username,
      password: hashedPassword,
    });
    await user.save();
    res.status(201).send('User registered successfully');
  } catch (error) {
    res.status(500).send('Error registering user');
  }
});

app.post('/login', async (req, res) => {
  const user = await User.findOne({ username: req.body.username });
  if (user == null) {
    return res.status(400).send('Cannot find user');
  }
  try {
    if (await bcrypt.compare(req.body.password, user.password)) {
      const accessToken = jwt.sign({ username: user.username }, process.env.JWT_SECRET);
      res.json({ accessToken: accessToken });
    } else {
      res.send('Not Allowed');
    }
  } catch {
    res.status(500).send();
  }
});

app.get('/messages', authenticateToken, async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [{ sender: req.user._id }, { receiver: req.user._id }],
    }).populate('sender', 'username').populate('receiver', 'username');
    res.json(messages);
  } catch (error) {
    res.status(500).send('Error fetching messages');
  }
});

app.post('/messages', authenticateToken, async (req, res) => {
  try {
    const sender = await User.findOne({ username: req.user.username });
    const receiver = await User.findOne({ username: req.body.receiver });
    const message = new Message({
      sender: sender._id,
      receiver: receiver._id,
      content: req.body.content,
    });
    await message.save();
    io.to(receiver.username).emit('newMessage', {
      sender: sender.username,
      content: req.body.content,
      timestamp: message.timestamp,
    });
    res.status(201).send('Message sent successfully');
  } catch (error) {
    res.status(500).send('Error sending message');
  }
});

app.post('/upload', authenticateToken, upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded');
  }
  res.status(200).json({ filename: req.file.filename });
});

app.get('/file/:filename', authenticateToken, (req, res) => {
  const filePath = path.join(__dirname, 'content', req.params.filename);
  if (fs.existsSync(filePath)) {
    res.sendFile(filePath);
  } else {
    res.status(404).send('File not found');
  }
});

app.post('/groups', authenticateToken, async (req, res) => {
  try {
    const group = new Group({
      name: req.body.name,
      members: [req.user._id, ...req.body.members],
      admins: [req.user._id],
    });
    await group.save();
    res.status(201).json(group);
  } catch (error) {
    res.status(500).send('Error creating group');
  }
});

app.get('/groups', authenticateToken, async (req, res) => {
  try {
    const groups = await Group.find({ members: req.user._id }).populate('members', 'username');
    res.json(groups);
  } catch (error) {
    res.status(500).send('Error fetching groups');
  }
});

app.post('/groups/:groupId/messages', authenticateToken, async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).send('Group not found');
    }
    const message = new Message({
      sender: req.user._id,
      content: req.body.content,
      isGroupMessage: true,
      groupId: group._id,
    });
    await message.save();
    group.members.forEach((memberId) => {
      io.to(memberId.toString()).emit('newGroupMessage', {
        groupId: group._id,
        sender: req.user.username,
        content: req.body.content,
        timestamp: message.timestamp,
      });
    });
    res.status(201).send('Group message sent successfully');
  } catch (error) {
    res.status(500).send('Error sending group message');
  }
});

io.use((socket, next) => {
  if (socket.handshake.query && socket.handshake.query.token) {
    jwt.verify(socket.handshake.query.token, process.env.JWT_SECRET, (err, decoded) => {
      if (err) return next(new Error('Authentication error'));
      socket.decoded = decoded;
      next();
    });
  } else {
    next(new Error('Authentication error'));
  }
}).on('connection', (socket) => {
  console.log('New client connected');
  socket.join(socket.decoded.username);

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));