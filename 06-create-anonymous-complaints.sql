-- =============================================
-- Create Anonymous Complaints Table
-- Class Voice - Store complaints anonymously (no username)
-- =============================================

-- Table: anonymous_complaints
-- Stores complaint_text only, with timestamps. No username column.

create table if not exists public.anonymous_complaints (
    id bigserial primary key,
    complaint_text text not null,
    created_at timestamptz not null default now(),
    -- optional metadata (not identifying):
    source_page text null,
    user_agent text null
);

-- Index for recent retrieval/administration
create index if not exists idx_anonymous_complaints_created_at on public.anonymous_complaints (created_at desc);

-- Enable Row Level Security
alter table public.anonymous_complaints enable row level security;

-- Allow INSERTs from anon/public clients, but block SELECT by default
-- (No SELECT policy is defined, so selects are denied under RLS for anon)
drop policy if exists allow_insert_anonymous_complaints on public.anonymous_complaints;
create policy allow_insert_anonymous_complaints
on public.anonymous_complaints
for insert
with check (true);

-- Optional: allow admins (service role) to read/update via SQL editor (has elevated key)
-- No explicit SELECT policy for anon; only service role or SQL editor can read.

-- Grants: allow inserts to anon/authenticated; keep reads blocked
GRANT INSERT ON public.anonymous_complaints TO anon;
GRANT INSERT ON public.anonymous_complaints TO authenticated;
GRANT USAGE ON SEQUENCE public.anonymous_complaints_id_seq TO anon;
GRANT USAGE ON SEQUENCE public.anonymous_complaints_id_seq TO authenticated;

-- Done.
