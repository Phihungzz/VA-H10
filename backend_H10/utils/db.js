import mongoose from 'mongoose';

const uri = process.env.MONGODB_URI;
let conn = null;

export async function connectDB() {
  if (!conn) {
    conn = await mongoose.connect(uri, {
      dbName: 'assistant_db',
    });
  }
  return conn;
}