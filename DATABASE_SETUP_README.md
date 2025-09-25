# Database Setup Instructions - KV Feedback Portal

## 🗑️ STEP 1: DELETE OLD SQL FILES

Delete the following old SQL files from your folder:
- `complete-fix.sql`
- `feedback-table-setup.sql`
- `fix-rls.sql`
- `fix-submission-time.sql`
- `quick-fix.sql`
- `supabase-setup.sql`

Keep only these NEW files:
- `01-create-feedback-table.sql`
- `02-add-indexes-triggers.sql`
- `03-setup-rls-policies.sql`
- `04-insert-sample-data.sql`
- `05-verify-setup.sql`

## 📝 STEP 2: RUN SQL FILES IN ORDER

Go to your Supabase Dashboard → SQL Editor and run these files in this exact order:

### 1️⃣ First: Create the Table
Run: **`01-create-feedback-table.sql`**
- ⚠️ WARNING: This will DROP any existing feedback_submissions table
- Creates a fresh table with all required columns including `username`

### 2️⃣ Second: Add Indexes and Triggers
Run: **`02-add-indexes-triggers.sql`**
- Adds performance indexes
- Sets up automatic character counting
- Adds timestamp triggers

### 3️⃣ Third: Setup Security
Run: **`03-setup-rls-policies.sql`**
- Enables Row Level Security
- Sets up access policies
- Grants permissions to users

### 4️⃣ Fourth: Add Sample Data (Optional)
Run: **`04-insert-sample-data.sql`**
- This is OPTIONAL - only for testing
- Adds 10 sample feedbacks

### 5️⃣ Fifth: Verify Everything
Run: **`05-verify-setup.sql`**
- Shows complete table structure
- Lists all indexes, triggers, and policies
- Runs a test insert and read
- Confirms everything is working

## ✅ What Each File Does

| File | Purpose | Safe to Re-run? |
|------|---------|-----------------|
| `01-create-feedback-table.sql` | Creates fresh table | ⚠️ NO - Deletes all data |
| `02-add-indexes-triggers.sql` | Adds indexes & triggers | ✅ YES |
| `03-setup-rls-policies.sql` | Sets up security | ✅ YES |
| `04-insert-sample-data.sql` | Adds test data | ✅ YES - Adds more data |
| `05-verify-setup.sql` | Checks everything | ✅ YES |

## 🎯 Expected Table Structure

After setup, your `feedback_submissions` table will have these columns:
- `id` (UUID) - Primary key
- `username` (VARCHAR) - User's name or "Anonymous"
- `feedback_text` (TEXT) - The feedback content
- `character_count` (INTEGER) - Auto-calculated
- `is_anonymous` (BOOLEAN) - Anonymous flag
- `is_approved` (BOOLEAN) - Approval status
- `is_reported` (BOOLEAN) - Report flag
- `report_count` (INTEGER) - Times reported
- `submission_date` (DATE) - Date of submission
- `submission_time` (TIMESTAMP) - Exact time
- `created_at` (TIMESTAMP) - Record creation
- `updated_at` (TIMESTAMP) - Last update

## 🚨 Troubleshooting

### If you get "table already exists" error:
- You need to DROP the existing table first
- Either run file `01` which includes DROP command
- Or manually run: `DROP TABLE feedback_submissions CASCADE;`

### If you get "column doesn't exist" error:
- Make sure you ran the files in order
- Start fresh with file `01`

### If feedbacks aren't showing:
- Check that RLS policies are set (file `03`)
- Verify `is_approved` is set to `true` for feedbacks
- Check the submission_date matches today

## 🎉 Success Indicators

When everything is set up correctly:
- File `05` shows all columns including `username`
- Test insert and read operations succeed
- Your website can post and display feedbacks
- No errors about missing columns

## 📞 Need Help?

If you encounter issues:
1. Start fresh by running file `01` (this will delete all data)
2. Run files `02`, `03` in order
3. Run file `05` to verify
4. Check the output messages for any errors
