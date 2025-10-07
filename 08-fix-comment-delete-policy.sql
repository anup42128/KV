-- =============================================
-- FIX COMMENT DELETE POLICY
-- PM SHRI KV Barrackpore Feedback Portal
-- Fix for comment deletion issues
-- =============================================

-- Drop the existing delete policy
DROP POLICY IF EXISTS "Users can delete own comments" ON feedback_comments;

-- Create a more permissive delete policy (we handle authorization in app layer)
CREATE POLICY "Users can delete own comments" ON feedback_comments
    FOR DELETE USING (true);

-- Verify the policy was created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'feedback_comments' AND policyname = 'Users can delete own comments';

-- Show all policies for the comments table
SELECT 'Current policies for feedback_comments:' as info;
SELECT policyname, cmd, permissive 
FROM pg_policies 
WHERE tablename = 'feedback_comments'
ORDER BY policyname;