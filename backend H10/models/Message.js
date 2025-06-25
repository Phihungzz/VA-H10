import mongoose from 'mongoose';

const MessageSchema = new mongoose.Schema({
  user: String,
  prompt: String,
  reply: String,
  createdAt: { type: Date, default: Date.now }
});
export default mongoose.models.Message || mongoose.model('Message', MessageSchema);