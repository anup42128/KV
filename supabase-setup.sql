-- =============================================
-- PM SHRI KV Barrackpore Feedback Portal
-- Supabase Database Setup Script
-- =============================================

-- Enable Row Level Security (RLS) for better security
-- This ensures users can only access their own data

-- =============================================
-- 1. USERS TABLE
-- Stores user authentication and profile information
-- =============================================

CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    full_name VARCHAR(100),
    user_type VARCHAR(20) DEFAULT 'student' CHECK (user_type IN ('student', 'teacher', 'admin')),
    class_section VARCHAR(10), -- e.g., '10A', '12B', etc.
    roll_number VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT username_length CHECK (LENGTH(username) >= 3),
    CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9_]+$')
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_class_section ON users(class_section);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- =============================================
-- 2. USER SESSIONS TABLE
-- Tracks user login sessions for security
-- =============================================

CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Create indexes for sessions
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_active ON user_sessions(is_active);

-- =============================================
-- 3. FEEDBACK SUBMISSIONS TABLE
-- Stores all feedback submitted by users
-- =============================================

CREATE TABLE IF NOT EXISTS feedback_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    feedback_text TEXT NOT NULL,
    character_count INTEGER,
    is_anonymous BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT false,
    is_reported BOOLEAN DEFAULT false,
    report_count INTEGER DEFAULT 0,
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

-- Create indexes for feedback
CREATE INDEX IF NOT EXISTS idx_feedback_username ON feedback_submissions(username);
CREATE INDEX IF NOT EXISTS idx_feedback_date ON feedback_submissions(submission_date);
CREATE INDEX IF NOT EXISTS idx_feedback_approved ON feedback_submissions(is_approved);

-- =============================================
-- 4. USER PROFILES TABLE (Extended Information)
-- Additional user information and preferences
-- =============================================

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    bio TEXT,
    avatar_url VARCHAR(500),
    preferences JSONB DEFAULT '{}',
    stats JSONB DEFAULT '{"feedback_count": 0, "total_ratings": 0, "average_rating": 0}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for user profiles
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON user_profiles(user_id);

-- =============================================
-- 5. AUDIT LOG TABLE
-- Tracks important user actions for security
-- =============================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for audit logs
CREATE INDEX IF NOT EXISTS idx_audit_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_created_at ON audit_logs(created_at);

-- =============================================
-- 6. FUNCTIONS AND TRIGGERS
-- Automated database functions for maintenance
-- =============================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON user_profiles;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically create user profile when user is created
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (user_id) VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS create_profile_on_user_insert ON users;

-- Trigger to create profile automatically
CREATE TRIGGER create_profile_on_user_insert
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile();

-- Function to clean up expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_sessions 
    WHERE expires_at < NOW() OR is_active = false;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- Security policies to protect user data
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can view own feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Users can insert own feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Users can update own feedback" ON feedback_submissions;
DROP POLICY IF EXISTS "Users can view own user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view their messages" ON messages;
DROP POLICY IF EXISTS "Users can insert their messages" ON messages;
DROP POLICY IF EXISTS "Users can update their messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their messages" ON messages;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- RLS Policies for feedback_submissions table
CREATE POLICY "Users can view own feedback" ON feedback_submissions
    FOR SELECT USING (auth.uid()::text = (SELECT id::text FROM users WHERE username = feedback_submissions.username));

CREATE POLICY "Users can insert own feedback" ON feedback_submissions
    FOR INSERT WITH CHECK (auth.uid()::text = (SELECT id::text FROM users WHERE username = feedback_submissions.username));

CREATE POLICY "Users can update own feedback" ON feedback_submissions
    FOR UPDATE USING (auth.uid()::text = (SELECT id::text FROM users WHERE username = feedback_submissions.username));

-- RLS Policies for user_profiles table
CREATE POLICY "Users can view own user_profiles" ON user_profiles
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own user_profiles" ON user_profiles
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- RLS Policies for messages table
-- Users can view messages they sent or received
CREATE POLICY "Users can view their messages" ON messages
    FOR SELECT USING (
        auth.uid()::text = sender_id::text OR 
        auth.uid()::text = receiver_id::text
    );

-- Users can insert messages they send
CREATE POLICY "Users can insert their messages" ON messages
    FOR INSERT WITH CHECK (auth.uid()::text = sender_id::text);

-- Users can update their own messages (if needed)
CREATE POLICY "Users can update their messages" ON messages
    FOR UPDATE USING (auth.uid()::text = sender_id::text);

-- Users can delete their own messages
CREATE POLICY "Users can delete their messages" ON messages
    FOR DELETE USING (auth.uid()::text = sender_id::text);

-- =============================================
-- 8. SAMPLE DATA (Optional - for testing)
-- =============================================

-- Insert sample users for testing (passwords should be hashed in real implementation)
-- Note: In production, never store plain text passwords!

/*
-- Sample Student Users
INSERT INTO users (username, password_hash, full_name, user_type, class_section, roll_number) VALUES
('john_doe', '$2b$12$hashedpassword1', 'John Doe', 'student', '10A', '001'),
('jane_smith', '$2b$12$hashedpassword2', 'Jane Smith', 'student', '10A', '002'),
('rajesh_kumar', '$2b$12$hashedpassword3', 'Rajesh Kumar', 'student', '12B', '015');

-- Sample Teacher Users
INSERT INTO users (username, password_hash, full_name, user_type) VALUES
('teacher_math', '$2b$12$hashedpassword4', 'Dr. Mathematics Teacher', 'teacher'),
('teacher_science', '$2b$12$hashedpassword5', 'Prof. Science Teacher', 'teacher');

-- Sample Admin User
INSERT INTO users (username, password_hash, full_name, user_type) VALUES
('admin_kv', '$2b$12$hashedpassword6', 'KV Administrator', 'admin');
*/

-- =============================================
-- 9. USEFUL VIEWS FOR ANALYTICS
-- =============================================

-- View for user statistics
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    u.id,
    u.username,
    u.user_type,
    u.class_section,
    COUNT(f.id) as total_feedback,
    0 as average_rating,  -- Placeholder since rating column doesn't exist
    MAX(f.created_at) as last_feedback_date,
    u.created_at as joined_date
FROM users u
LEFT JOIN feedback_submissions f ON u.username = f.username
GROUP BY u.id, u.username, u.user_type, u.class_section, u.created_at;

-- View for daily feedback summary
CREATE OR REPLACE VIEW daily_feedback_summary AS
SELECT 
    submission_date,
    COUNT(*) as total_feedback,
    COUNT(*) FILTER (WHERE is_approved = true) as approved_feedback,
    0 as average_rating,  -- Placeholder since rating column doesn't exist
    COUNT(DISTINCT username) as unique_users
FROM feedback_submissions
GROUP BY submission_date
ORDER BY submission_date DESC;

-- =============================================
-- 10. MESSAGES TABLE
-- Stores private messages between users
-- =============================================

CREATE TABLE IF NOT EXISTS messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT content_length CHECK (LENGTH(content) >= 1)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_participants ON messages(sender_id, receiver_id);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Note: RLS policies for messages table are defined in the main RLS policies section above
-- to avoid duplication and ensure proper DROP/CREATE policy handling

COMMENT ON TABLE messages IS 'Private messages between users';

-- =============================================
-- 10. MAINTENANCE PROCEDURES
-- =============================================

-- Create a function to get user statistics
CREATE OR REPLACE FUNCTION get_user_dashboard_stats(p_username VARCHAR)
RETURNS TABLE(
    feedback_count BIGINT,
    average_rating NUMERIC,
    total_views BIGINT,
    streak_days INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(f.id) as feedback_count,
        0 as average_rating,  -- Placeholder since rating column doesn't exist
        COUNT(f.id) as total_views, -- Placeholder - implement view tracking separately
        7 as streak_days -- Placeholder - implement streak calculation
    FROM feedback_submissions f
    WHERE f.username = p_username;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SETUP COMPLETE
-- =============================================

-- Comments for maintenance:
-- 1. Remember to hash passwords using bcrypt or similar before storing
-- 2. Regularly clean up expired sessions using cleanup_expired_sessions()
-- 3. Monitor audit logs for security
-- 4. Backup database regularly
-- 5. Update user statistics periodically

-- To run session cleanup (recommended to run daily via cron):
-- SELECT cleanup_expired_sessions();

COMMENT ON TABLE users IS 'Main users table storing authentication and basic profile information';
COMMENT ON TABLE user_sessions IS 'Active user sessions for security tracking';
COMMENT ON TABLE feedback_submissions IS 'All feedback submitted by users';
COMMENT ON TABLE user_profiles IS 'Extended user profile information and preferences';
COMMENT ON TABLE audit_logs IS 'Security audit trail for important actions';
COMMENT ON TABLE messages IS 'Private messages between users';
