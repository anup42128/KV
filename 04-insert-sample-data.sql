-- =============================================
-- STEP 4: INSERT SAMPLE DATA (OPTIONAL)
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================
-- Run this AFTER setting up RLS (03-setup-rls-policies.sql)
-- This is OPTIONAL - only for testing purposes
-- =============================================

-- Insert some sample feedbacks for testing
INSERT INTO feedback_submissions (username, feedback_text, is_anonymous) VALUES
    ('John Doe', 'The teaching methods in mathematics class are excellent!', false),
    ('Anonymous', 'Library needs more reference books for competitive exams.', true),
    ('Jane Smith', 'Sports facilities are well maintained. Thank you!', false),
    ('Anonymous', 'Cafeteria food quality has improved this month.', true),
    ('Raj Kumar', 'Request for more practical sessions in science lab.', false),
    ('Anonymous', 'The new computer lab is fantastic!', true),
    ('Priya Sharma', 'Teachers are very supportive and helpful.', false),
    ('Anonymous', 'Please extend library hours during exam time.', true),
    ('Student123', 'Great initiative with the feedback system!', false),
    ('Anonymous', 'More cultural activities would be appreciated.', true);

-- Verify data was inserted
SELECT 
    id,
    username,
    LEFT(feedback_text, 50) as feedback_preview,
    is_anonymous,
    character_count,
    submission_date,
    TO_CHAR(submission_time, 'DD Mon YYYY HH24:MI') as formatted_time
FROM 
    feedback_submissions
ORDER BY 
    submission_time DESC;

-- Show statistics
SELECT 
    COUNT(*) as total_feedbacks,
    COUNT(CASE WHEN is_anonymous = true THEN 1 END) as anonymous_feedbacks,
    COUNT(CASE WHEN is_anonymous = false THEN 1 END) as named_feedbacks,
    AVG(character_count) as avg_character_count,
    MAX(character_count) as max_character_count
FROM 
    feedback_submissions;
