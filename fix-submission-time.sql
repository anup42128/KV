-- =============================================
-- Fix submission_time Column Issue
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================

-- First, check if the column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'feedback_submissions';

-- If submission_time column doesn't exist, add it
DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'submission_time'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN submission_time TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        
        -- Update existing rows to have a submission_time
        UPDATE feedback_submissions 
        SET submission_time = created_at 
        WHERE submission_time IS NULL AND created_at IS NOT NULL;
        
        -- If created_at doesn't exist either, use current time
        UPDATE feedback_submissions 
        SET submission_time = NOW() 
        WHERE submission_time IS NULL;
        
        RAISE NOTICE 'Column submission_time has been added successfully';
    ELSE
        RAISE NOTICE 'Column submission_time already exists';
    END IF;
END $$;

-- Create index if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_feedback_submission_time 
ON feedback_submissions(submission_time DESC);

-- Verify the table structure
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

-- Check if there are any records and display a sample
SELECT 
    id,
    username,
    feedback_text,
    submission_date,
    submission_time,
    created_at
FROM 
    feedback_submissions
LIMIT 5;

-- Grant necessary permissions
GRANT ALL ON feedback_submissions TO anon;
GRANT ALL ON feedback_submissions TO authenticated;
