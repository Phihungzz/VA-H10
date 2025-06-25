import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema({
  name: String,
  password: String,
});
export default mongoose.models.User || mongoose.model('User', UserSchema);