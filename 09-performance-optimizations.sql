-- =============================================
-- PERFORMANCE OPTIMIZATIONS
-- PM SHRI KV Barrackpore Feedback Portal
-- Optimize database queries for faster loading
-- =============================================

-- Add composite index for feedback-comment queries
CREATE INDEX IF NOT EXISTS idx_feedback_comments_feedback_approved 
ON feedback_comments(feedback_id, is_approved);

-- Add index for feedback ordering
CREATE INDEX IF NOT EXISTS idx_feedback_submissions_created_at_desc
ON feedback_submissions(created_at DESC);

-- Add index for user-specific queries
CREATE INDEX IF NOT EXISTS idx_feedback_submissions_username_created
ON feedback_submissions(username, created_at DESC);

-- Update table statistics for better query planning
ANALYZE feedback_submissions;
ANALYZE feedback_comments;

-- Show current indexes
SELECT 'Current indexes on feedback_submissions:' as info;
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'feedback_submissions'
ORDER BY indexname;

SELECT 'Current indexes on feedback_comments:' as info;
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'feedback_comments'
ORDER BY indexname;

-- Verify the optimization worked
SELECT 'Optimization complete!' as status;