import mongoose from 'mongoose';
import { MONGODB_URI } from './utils.js';
export default function connectDB() {
  if (!MONGODB_URI) {
    console.error('MongoDB connection string missing. Set MONGODB_URI in backend/.env.');
    process.exit(1);
  }

  mongoose.connect(MONGODB_URI).catch((err) => {
    console.error(`MongoDB connection error: ${err.message}`);
    process.exit(1);
  });

  const dbConnection = mongoose.connection;

  dbConnection.once('open', () => {
    console.log('Database connected');
  });

  dbConnection.on('error', (err) => {
    console.error(`MongoDB connection error: ${err.message}`);
  });
  return;
}
