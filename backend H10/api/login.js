import { connectDB } from '../utils/db.js';
import User from '../models/User.js';

export default async function handler(req, res) {
  await connectDB();
  const { name, password } = req.body;
  const user = await User.findOne({ name, password });
  if (!user) return res.status(200).json({ success: false, message: 'Sai thông tin đăng nhập' });
  return res.status(200).json({ success: true });
}
