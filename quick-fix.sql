-- QUICK FIX: Disable Row Level Security for testing
-- Run this in your Supabase SQL Editor

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Confirmation message
SELECT 'RLS disabled - your app should work now!' as message;
