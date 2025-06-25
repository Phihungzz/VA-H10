import { connectDB } from '../utils/db.js';
import User from '../models/User.js';

export default async function handler(req, res) {
  await connectDB();
  const { name, password } = req.body;
  const existing = await User.findOne({ name });
  if (existing) return res.status(200).json({ success: false, message: 'Tên đã tồn tại' });
  await User.create({ name, password });
  return res.status(200).json({ success: true });
}