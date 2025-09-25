-- =============================================
-- STEP 5: VERIFY COMPLETE SETUP (CORRECTED VERSION)
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================
-- Run this LAST to verify everything is set up correctly
-- =============================================

-- 1. Show table structure
SELECT 
    '=== TABLE STRUCTURE ===' as section;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'feedback_submissions'
ORDER BY 
    ordinal_position;

-- 2. Show indexes
SELECT 
    '=== INDEXES ===' as section;

SELECT 
    indexname,
    indexdef
FROM 
    pg_indexes
WHERE 
    tablename = 'feedback_submissions'
ORDER BY 
    indexname;

-- 3. Show triggers
SELECT 
    '=== TRIGGERS ===' as section;

SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_orientation
FROM 
    information_schema.triggers
WHERE 
    event_object_table = 'feedback_submissions';

-- 4. Show RLS status
SELECT 
    '=== ROW LEVEL SECURITY ===' as section;

SELECT 
    tablename,
    rowsecurity
FROM 
    pg_tables
WHERE 
    tablename = 'feedback_submissions';

-- 5. Show RLS policies
SELECT 
    '=== RLS POLICIES ===' as section;

SELECT 
    policyname,
    cmd,
    permissive
FROM 
    pg_policies
WHERE 
    tablename = 'feedback_submissions';

-- 6. Show constraints
SELECT 
    '=== CONSTRAINTS ===' as section;

SELECT 
    conname as constraint_name,
    contype as constraint_type
FROM 
    pg_constraint
WHERE 
    conrelid = 'feedback_submissions'::regclass;

-- 7. Final test: Try inserting a test record
SELECT 
    '=== INSERT TEST ===' as section;

INSERT INTO feedback_submissions (username, feedback_text, is_anonymous) 
VALUES ('Test User', 'This is a test feedback to verify the system works!', false)
RETURNING id, username, feedback_text, character_count, submission_time;

-- 8. Verify the test record can be read
SELECT 
    '=== READ TEST ===' as section;

SELECT 
    username,
    feedback_text,
    character_count,
    submission_date,
    TO_CHAR(submission_time, 'DD Mon YYYY HH24:MI:SS') as submission_time
FROM 
    feedback_submissions
WHERE 
    username = 'Test User'
ORDER BY 
    created_at DESC
LIMIT 1;

-- 9. Clean up test record
DELETE FROM feedback_submissions 
WHERE username = 'Test User' AND feedback_text = 'This is a test feedback to verify the system works!';

-- 10. Final summary
SELECT 
    '=== SETUP COMPLETE ===' as status,
    COUNT(*) as total_feedbacks,
    'Database is ready for use!' as message
FROM 
    feedback_submissions;
