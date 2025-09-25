-- =============================================
-- Feedback Submissions Table Setup
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================

-- Drop existing table if needed (be careful with this in production!)
-- DROP TABLE IF EXISTS feedback_submissions CASCADE;

-- Create the feedback_submissions table with updated structure
CREATE TABLE IF NOT EXISTS feedback_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username VARCHAR(100) NOT NULL, -- Will be 'Anonymous' for anonymous posts
    feedback_text TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT false,
    submission_date DATE DEFAULT CURRENT_DATE,
    submission_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    character_count INTEGER,
    is_approved BOOLEAN DEFAULT true, -- Auto-approve for now
    is_reported BOOLEAN DEFAULT false,
    report_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT feedback_text_length CHECK (LENGTH(feedback_text) <= 200),
    CONSTRAINT character_count_check CHECK (character_count <= 200)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_feedback_submission_date ON feedback_submissions(submission_date DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_submission_time ON feedback_submissions(submission_time DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_is_approved ON feedback_submissions(is_approved);
CREATE INDEX IF NOT EXISTS idx_feedback_is_anonymous ON feedback_submissions(is_anonymous);

-- Enable Row Level Security (RLS)
ALTER TABLE feedback_submissions ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust as needed)
-- Policy to allow anyone to read approved feedbacks
CREATE POLICY "Public can view approved feedbacks" ON feedback_submissions
    FOR SELECT USING (is_approved = true);

-- Policy to allow authenticated users to insert feedbacks
CREATE POLICY "Anyone can insert feedback" ON feedback_submissions
    FOR INSERT WITH CHECK (true);

-- Policy to allow users to update their own feedbacks (optional)
-- CREATE POLICY "Users can update own feedback" ON feedback_submissions
--     FOR UPDATE USING (username = current_user);

-- Function to automatically set character count
CREATE OR REPLACE FUNCTION set_character_count()
RETURNS TRIGGER AS $$
BEGIN
    NEW.character_count := LENGTH(NEW.feedback_text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set character count
DROP TRIGGER IF EXISTS set_feedback_character_count ON feedback_submissions;
CREATE TRIGGER set_feedback_character_count
    BEFORE INSERT OR UPDATE ON feedback_submissions
    FOR EACH ROW
    EXECUTE FUNCTION set_character_count();

-- Function to clean up old feedbacks (older than 24 hours)
CREATE OR REPLACE FUNCTION cleanup_old_feedbacks()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM feedback_submissions 
    WHERE submission_date < CURRENT_DATE;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Sample data for testing (optional - remove in production)
/*
INSERT INTO feedback_submissions (username, feedback_text, is_anonymous, character_count) VALUES
('John Doe', 'The teaching methods in mathematics class are excellent. Really enjoying the interactive sessions!', false, 95),
('Anonymous', 'Library needs more reference books for competitive exams.', true, 55),
('Jane Smith', 'Sports facilities are well maintained. Thank you!', false, 48),
('Anonymous', 'Cafeteria food quality has improved a lot this month.', true, 52),
('Raj Kumar', 'Request for more practical sessions in science lab.', false, 50);
*/

-- View to get today's feedbacks
CREATE OR REPLACE VIEW todays_feedbacks AS
SELECT 
    id,
    username,
    feedback_text,
    is_anonymous,
    submission_time,
    character_count,
    TO_CHAR(submission_time, 'Mon DD, YYYY') as formatted_date,
    TO_CHAR(submission_time, 'HH12:MI AM') as formatted_time
FROM feedback_submissions
WHERE submission_date = CURRENT_DATE
    AND is_approved = true
ORDER BY submission_time DESC;

-- Grant necessary permissions (adjust based on your setup)
GRANT ALL ON feedback_submissions TO anon;
GRANT ALL ON feedback_submissions TO authenticated;
GRANT SELECT ON todays_feedbacks TO anon;
GRANT SELECT ON todays_feedbacks TO authenticated;

-- Comments for documentation
COMMENT ON TABLE feedback_submissions IS 'Stores all feedback submissions from students and teachers';
COMMENT ON COLUMN feedback_submissions.username IS 'Username of the person posting feedback, or "Anonymous" for anonymous posts';
COMMENT ON COLUMN feedback_submissions.is_anonymous IS 'Flag to indicate if the feedback was posted anonymously';
COMMENT ON COLUMN feedback_submissions.character_count IS 'Number of characters in the feedback text';
COMMENT ON COLUMN feedback_submissions.is_reported IS 'Flag to indicate if the feedback has been reported';
COMMENT ON COLUMN feedback_submissions.report_count IS 'Number of times this feedback has been reported';
