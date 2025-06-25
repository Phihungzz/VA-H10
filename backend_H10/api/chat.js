import { GoogleGenerativeAI } from '@google/generative-ai';
import { connectDB } from '../utils/db.js';
import Message from '../models/Message.js';

export default async function handler(req, res) {
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error('Thiếu biến môi trường GEMINI_API_KEY');
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    await connectDB();

    const { message, user } = req.body;
    if (!message || !user) {
      throw new Error('Thiếu message hoặc user trong body');
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    const prompt = `Bạn là trợ lý ảo thông minh, đang trò chuyện với người tên "${user}". Hãy trả lời thân thiện và tự nhiên:\n\nCâu hỏi: ${message}`;
    const result = await model.generateContent(prompt);
    const text = result.response.text();

    await Message.create({ user, prompt: message, reply: text });

    return res.status(200).json({ reply: text });
  } catch (err) {
    console.error("🔥 Lỗi server:", err);
    return res.status(500).json({ reply: '❌ Lỗi khi xử lý yêu cầu.', error: err.message });
  }
}
