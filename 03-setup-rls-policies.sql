-- =============================================
-- STEP 3: SETUP ROW LEVEL SECURITY (RLS)
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================
-- Run this AFTER creating indexes (02-add-indexes-triggers.sql)
-- =============================================

-- Enable Row Level Security on the table
ALTER TABLE feedback_submissions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (cleanup)
DROP POLICY IF EXISTS "Public can view approved feedbacks" ON feedback_submissions;
DROP POLICY IF EXISTS "Anyone can insert feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Anyone can update report count" ON feedback_submissions;
DROP POLICY IF EXISTS "Read approved feedbacks" ON feedback_submissions;
DROP POLICY IF EXISTS "Insert feedbacks" ON feedback_submissions;
DROP POLICY IF EXISTS "Update feedbacks for reporting" ON feedback_submissions;

-- Policy 1: Allow anyone to read approved feedbacks
CREATE POLICY "Read approved feedbacks" 
    ON feedback_submissions
    FOR SELECT
    USING (is_approved = true);

-- Policy 2: Allow anyone to insert new feedbacks
CREATE POLICY "Insert feedbacks" 
    ON feedback_submissions
    FOR INSERT
    WITH CHECK (true);

-- Policy 3: Allow updating feedbacks (for reporting functionality)
CREATE POLICY "Update feedbacks for reporting" 
    ON feedback_submissions
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Grant necessary permissions to anonymous and authenticated users
GRANT SELECT ON feedback_submissions TO anon;
GRANT INSERT ON feedback_submissions TO anon;
GRANT UPDATE ON feedback_submissions TO anon;

GRANT SELECT ON feedback_submissions TO authenticated;
GRANT INSERT ON feedback_submissions TO authenticated;
GRANT UPDATE ON feedback_submissions TO authenticated;

-- Also grant usage on the sequences (for UUID generation)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Verify RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM 
    pg_tables
WHERE 
    tablename = 'feedback_submissions';

-- List all policies
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM 
    pg_policies
WHERE 
    tablename = 'feedback_submissions';
