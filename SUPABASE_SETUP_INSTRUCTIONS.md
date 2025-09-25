# 🆕 Create New Supabase Project

## Step 1: Create Project
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Choose organization
4. Set project name: "KV Barrackpore Feedback Portal"
5. Set database password (save this!)
6. Choose region (closest to India)
7. Click "Create new project"

## Step 2: Get New Credentials
After project creation (2-3 minutes):
1. Go to Project Settings → API
2. Copy your **Project URL** 
3. Copy your **anon public key**

## Step 3: Update Configuration
Replace in supabase-config.js:
```javascript
const SUPABASE_CONFIG = {
    url: 'YOUR_NEW_PROJECT_URL_HERE',
    apiKey: 'YOUR_NEW_ANON_KEY_HERE'
};
```

## Step 4: Set Up Database Tables
Run the SQL commands from create-tables.sql in your Supabase SQL Editor.
