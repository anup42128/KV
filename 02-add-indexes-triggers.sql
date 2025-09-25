-- =============================================
-- STEP 2: ADD INDEXES AND TRIGGERS
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================
-- Run this AFTER creating the table (01-create-feedback-table.sql)
-- =============================================

-- Create indexes for better query performance
CREATE INDEX idx_feedback_submission_date ON feedback_submissions(submission_date DESC);
CREATE INDEX idx_feedback_submission_time ON feedback_submissions(submission_time DESC);
CREATE INDEX idx_feedback_created_at ON feedback_submissions(created_at DESC);
CREATE INDEX idx_feedback_is_approved ON feedback_submissions(is_approved);
CREATE INDEX idx_feedback_is_anonymous ON feedback_submissions(is_anonymous);
CREATE INDEX idx_feedback_username ON feedback_submissions(username);
CREATE INDEX idx_feedback_date_approved ON feedback_submissions(submission_date DESC, is_approved);

-- Function to automatically set character count
CREATE OR REPLACE FUNCTION set_character_count()
RETURNS TRIGGER AS $$
BEGIN
    NEW.character_count := LENGTH(NEW.feedback_text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set character count on insert/update
CREATE TRIGGER set_feedback_character_count
    BEFORE INSERT OR UPDATE OF feedback_text ON feedback_submissions
    FOR EACH ROW
    EXECUTE FUNCTION set_character_count();

-- Create trigger to update the updated_at timestamp
CREATE TRIGGER update_feedback_updated_at
    BEFORE UPDATE ON feedback_submissions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Verify indexes were created
SELECT 
    indexname,
    indexdef
FROM 
    pg_indexes
WHERE 
    tablename = 'feedback_submissions'
ORDER BY 
    indexname;

-- Verify triggers were created
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM 
    information_schema.triggers
WHERE 
    event_object_table = 'feedback_submissions';
