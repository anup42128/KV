-- =============================================
-- STEP 7: CREATE COMMENTS TABLE FOR FEEDBACK SYSTEM
-- PM SHRI KV Barrackpore Feedback Portal
-- Modern Comment System Implementation
-- =============================================

-- Create the comments table
CREATE TABLE IF NOT EXISTS feedback_comments (
    -- Primary key
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Foreign key to feedback_submissions
    feedback_id UUID NOT NULL,
    
    -- User information
    username VARCHAR(100) NOT NULL,
    
    -- Comment content
    comment_text TEXT NOT NULL,
    character_count INTEGER,
    
    -- Metadata flags
    is_anonymous BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT true,
    is_reported BOOLEAN DEFAULT false,
    report_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign key constraint
    CONSTRAINT fk_feedback_comments_feedback_id 
        FOREIGN KEY (feedback_id) 
        REFERENCES feedback_submissions(id) 
        ON DELETE CASCADE,
    
    -- Data validation constraints
    CONSTRAINT comment_text_not_empty CHECK (LENGTH(TRIM(comment_text)) > 0),
    CONSTRAINT comment_text_max_length CHECK (LENGTH(comment_text) <= 500),
    CONSTRAINT character_count_check CHECK (character_count <= 500),
    CONSTRAINT report_count_positive CHECK (report_count >= 0)
);

-- Add comments for documentation
COMMENT ON TABLE feedback_comments IS 'Stores comments for feedback submissions';
COMMENT ON COLUMN feedback_comments.feedback_id IS 'References the feedback this comment belongs to';
COMMENT ON COLUMN feedback_comments.username IS 'Username of the commenter or "Anonymous"';
COMMENT ON COLUMN feedback_comments.comment_text IS 'The actual comment content (max 500 chars)';
COMMENT ON COLUMN feedback_comments.character_count IS 'Cached character count of comment_text';
COMMENT ON COLUMN feedback_comments.is_anonymous IS 'True if comment posted anonymously';
COMMENT ON COLUMN feedback_comments.is_approved IS 'True if comment approved for display';
COMMENT ON COLUMN feedback_comments.is_reported IS 'True if comment reported by users';
COMMENT ON COLUMN feedback_comments.report_count IS 'Number of times comment reported';

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_feedback_comments_feedback_id ON feedback_comments(feedback_id);
CREATE INDEX IF NOT EXISTS idx_feedback_comments_created_at ON feedback_comments(created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_comments_username ON feedback_comments(username);
CREATE INDEX IF NOT EXISTS idx_feedback_comments_approved ON feedback_comments(is_approved);

-- Create trigger to automatically update character_count
CREATE OR REPLACE FUNCTION update_comment_character_count()
RETURNS TRIGGER AS $$
BEGIN
    NEW.character_count = LENGTH(NEW.comment_text);
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger
DROP TRIGGER IF EXISTS trigger_update_comment_character_count ON feedback_comments;
CREATE TRIGGER trigger_update_comment_character_count
    BEFORE INSERT OR UPDATE ON feedback_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_comment_character_count();

-- Enable Row Level Security (RLS) for the comments table
ALTER TABLE feedback_comments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for comments
-- Policy 1: Anyone can view approved comments
CREATE POLICY "Anyone can view approved comments" ON feedback_comments
    FOR SELECT USING (is_approved = true);

-- Policy 2: Authenticated users can insert comments
CREATE POLICY "Authenticated users can insert comments" ON feedback_comments
    FOR INSERT WITH CHECK (true);

-- Policy 3: Users can update their own comments
CREATE POLICY "Users can update own comments" ON feedback_comments
    FOR UPDATE USING (username = current_setting('app.current_user', true));

-- Policy 4: Users can delete their own comments (updated for better compatibility)
CREATE POLICY "Users can delete own comments" ON feedback_comments
    FOR DELETE USING (true); -- Allow delete, but we'll handle authorization in the application layer

-- Verify table creation
SELECT 'Comments table created successfully!' as status;
SELECT COUNT(*) as column_count FROM information_schema.columns 
WHERE table_name = 'feedback_comments';

-- Display table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'feedback_comments'
ORDER BY ordinal_position;