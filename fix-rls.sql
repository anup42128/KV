-- =============================================
-- FIX ROW LEVEL SECURITY FOR TESTING
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================

-- Temporarily disable RLS on all tables for testing
-- This allows your application to insert/update data without authentication

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;

-- Drop any existing policies that might be interfering
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can view own feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Users can insert own feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Users can update own feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Users can view own user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own user_profiles" ON user_profiles;

-- Create a permissive policy for testing (allows all operations)
-- WARNING: This is for development only - not for production!

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations for testing" ON users FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations for testing" ON user_sessions FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE feedback_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations for testing" ON feedback_submissions FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations for testing" ON user_profiles FOR ALL USING (true) WITH CHECK (true);

-- If audit_logs table exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'audit_logs') THEN
        ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
        EXECUTE 'CREATE POLICY "Allow all operations for testing" ON audit_logs FOR ALL USING (true) WITH CHECK (true)';
    END IF;
END $$;

-- Verify the changes
SELECT schemaname, tablename, rowsecurity, hasrlspolicy 
FROM pg_tables 
LEFT JOIN (
    SELECT schemaname, tablename, true as hasrlspolicy 
    FROM pg_policies 
    GROUP BY schemaname, tablename
) policies USING (schemaname, tablename)
WHERE tablename IN ('users', 'user_sessions', 'feedback_submissions', 'user_profiles', 'audit_logs')
AND schemaname = 'public';

-- Show a success message
SELECT 'Row Level Security policies updated for testing. Your application should now work!' as status;
