import fs from 'fs/promises';
import mongoose from 'mongoose';
import Post from '../models/post.js';
import { MONGODB_URI } from '../config/utils.js';

if (!MONGODB_URI) {
  console.error('MongoDB connection string missing. Set MONGODB_URI in backend/.env.');
  process.exit(1);
}

const samplePostsPath = new URL('../data/sample_posts.json', import.meta.url);
const samplePosts = JSON.parse(await fs.readFile(samplePostsPath, 'utf8')).map((post) => ({
  ...post,
  _id: post._id?.$oid,
  timeOfPost: post.timeOfPost?.$date ? new Date(post.timeOfPost.$date) : post.timeOfPost,
}));

try {
  await mongoose.connect(MONGODB_URI);
  await Post.deleteMany({});
  await Post.insertMany(samplePosts);
  console.log(`Seeded ${samplePosts.length} posts.`);
} catch (err) {
  console.error(`Seed failed: ${err.message}`);
  process.exitCode = 1;
} finally {
  await mongoose.disconnect();
}
