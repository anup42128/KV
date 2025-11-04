-- =============================================
-- MESSAGES TABLE
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

COMMENT ON TABLE messages IS 'Private messages between users';