-- =============================================
-- STEP 1: CREATE FEEDBACK TABLE FROM SCRATCH
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================
-- WARNING: This will DROP and RECREATE the table
-- Only run this if you want to start fresh!
-- =============================================

-- Drop the existing table if it exists (this will delete all data!)
DROP TABLE IF EXISTS feedback_submissions CASCADE;

-- Create the feedback_submissions table with all required columns
CREATE TABLE feedback_submissions (
    -- Primary key
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- User information
    username VARCHAR(100) NOT NULL,
    
    -- Feedback content
    feedback_text TEXT NOT NULL,
    character_count INTEGER,
    
    -- Metadata flags
    is_anonymous BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT true,
    is_reported BOOLEAN DEFAULT false,
    report_count INTEGER DEFAULT 0,
    
    -- Timestamps
    submission_date DATE DEFAULT CURRENT_DATE,
    submission_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT feedback_text_not_empty CHECK (LENGTH(TRIM(feedback_text)) > 0),
    CONSTRAINT feedback_text_max_length CHECK (LENGTH(feedback_text) <= 200),
    CONSTRAINT character_count_check CHECK (character_count <= 200),
    CONSTRAINT report_count_positive CHECK (report_count >= 0)
);

-- Add comments for documentation
COMMENT ON TABLE feedback_submissions IS 'Stores all feedback submissions from students and teachers';
COMMENT ON COLUMN feedback_submissions.username IS 'Username or "Anonymous" for anonymous posts';
COMMENT ON COLUMN feedback_submissions.feedback_text IS 'The actual feedback content (max 200 chars)';
COMMENT ON COLUMN feedback_submissions.character_count IS 'Cached character count of feedback_text';
COMMENT ON COLUMN feedback_submissions.is_anonymous IS 'True if posted anonymously';
COMMENT ON COLUMN feedback_submissions.is_approved IS 'True if approved for display';
COMMENT ON COLUMN feedback_submissions.is_reported IS 'True if reported by users';
COMMENT ON COLUMN feedback_submissions.report_count IS 'Number of times reported';
COMMENT ON COLUMN feedback_submissions.submission_date IS 'Date of submission (for daily filtering)';
COMMENT ON COLUMN feedback_submissions.submission_time IS 'Exact time of submission';
COMMENT ON COLUMN feedback_submissions.created_at IS 'Database record creation time';

-- Verify table was created
SELECT 'Table created successfully!' as status;
SELECT COUNT(*) as column_count FROM information_schema.columns 
WHERE table_name = 'feedback_submissions';
