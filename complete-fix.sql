-- =============================================
-- Complete Fix for Feedback Submissions Table
-- PM SHRI KV Barrackpore Feedback Portal
-- =============================================

-- Step 1: Check current table structure
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

-- Step 2: Add missing columns if they don't exist
DO $$ 
BEGIN 
    -- Add submission_time column
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'submission_time'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN submission_time TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added submission_time column';
    END IF;
    
    -- Add created_at column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'created_at'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added created_at column';
    END IF;
    
    -- Add submission_date column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'submission_date'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN submission_date DATE DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Added submission_date column';
    END IF;
    
    -- Add is_approved column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'is_approved'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN is_approved BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_approved column';
    END IF;
    
    -- Add character_count column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'character_count'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN character_count INTEGER;
        RAISE NOTICE 'Added character_count column';
    END IF;
    
    -- Add is_anonymous column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'is_anonymous'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN is_anonymous BOOLEAN DEFAULT false;
        RAISE NOTICE 'Added is_anonymous column';
    END IF;
    
    -- Add is_reported column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'is_reported'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN is_reported BOOLEAN DEFAULT false;
        RAISE NOTICE 'Added is_reported column';
    END IF;
    
    -- Add report_count column if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'feedback_submissions' 
        AND column_name = 'report_count'
    ) THEN 
        ALTER TABLE feedback_submissions 
        ADD COLUMN report_count INTEGER DEFAULT 0;
        RAISE NOTICE 'Added report_count column';
    END IF;
END $$;

-- Step 3: Update existing rows with proper values
UPDATE feedback_submissions 
SET submission_time = COALESCE(submission_time, created_at, NOW())
WHERE submission_time IS NULL;

UPDATE feedback_submissions 
SET created_at = COALESCE(created_at, submission_time, NOW())
WHERE created_at IS NULL;

UPDATE feedback_submissions 
SET submission_date = COALESCE(submission_date, DATE(submission_time), CURRENT_DATE)
WHERE submission_date IS NULL;

UPDATE feedback_submissions 
SET character_count = LENGTH(feedback_text)
WHERE character_count IS NULL;

-- Step 4: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_feedback_submission_time 
ON feedback_submissions(submission_time DESC);

CREATE INDEX IF NOT EXISTS idx_feedback_created_at
ON feedback_submissions(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_feedback_submission_date 
ON feedback_submissions(submission_date DESC);

CREATE INDEX IF NOT EXISTS idx_feedback_is_approved 
ON feedback_submissions(is_approved);

-- Step 5: Enable RLS if not already enabled
ALTER TABLE feedback_submissions ENABLE ROW LEVEL SECURITY;

-- Step 6: Create or replace RLS policies
DROP POLICY IF EXISTS "Public can view approved feedbacks" ON feedback_submissions;
CREATE POLICY "Public can view approved feedbacks" ON feedback_submissions
    FOR SELECT USING (is_approved = true);

DROP POLICY IF EXISTS "Anyone can insert feedback" ON feedback_submissions;
CREATE POLICY "Anyone can insert feedback" ON feedback_submissions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Anyone can update report count" ON feedback_submissions;
CREATE POLICY "Anyone can update report count" ON feedback_submissions
    FOR UPDATE USING (true)
    WITH CHECK (true);

-- Step 7: Grant permissions
GRANT ALL ON feedback_submissions TO anon;
GRANT ALL ON feedback_submissions TO authenticated;

-- Step 8: Create or replace the character count trigger function
CREATE OR REPLACE FUNCTION set_character_count()
RETURNS TRIGGER AS $$
BEGIN
    NEW.character_count := LENGTH(NEW.feedback_text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 9: Create trigger if it doesn't exist
DROP TRIGGER IF EXISTS set_feedback_character_count ON feedback_submissions;
CREATE TRIGGER set_feedback_character_count
    BEFORE INSERT OR UPDATE ON feedback_submissions
    FOR EACH ROW
    EXECUTE FUNCTION set_character_count();

-- Step 10: Verify the final table structure
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

-- Step 11: Show sample data to verify everything is working
SELECT 
    id,
    username,
    LEFT(feedback_text, 50) as feedback_preview,
    is_anonymous,
    submission_date,
    submission_time,
    created_at,
    character_count,
    is_approved,
    is_reported,
    report_count
FROM 
    feedback_submissions
ORDER BY 
    created_at DESC
LIMIT 5;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ Database fix completed successfully!';
    RAISE NOTICE '📊 All required columns are now present';
    RAISE NOTICE '🔐 RLS policies are configured';
    RAISE NOTICE '⚡ Indexes are created for performance';
    RAISE NOTICE '🎯 Triggers are set up for automatic character counting';
END $$;
