-- Migration: Add 'type' and 'thumbnail_path' columns to content table
-- Safe to run multiple times; uses IF NOT EXISTS where supported.
-- Run this in Supabase SQL editor or via psql connected to your database.

-- Add textual 'type' column to categorize content (devotion, sermon, event, ...)
ALTER TABLE IF EXISTS public.content
  ADD COLUMN IF NOT EXISTS "type" text;

-- Add thumbnail_path column to store the storage key if desired
ALTER TABLE IF EXISTS public.content
  ADD COLUMN IF NOT EXISTS thumbnail_path text;

-- Optionally index the type column for faster filtering by section
CREATE INDEX IF NOT EXISTS idx_content_type ON public.content ("type");

-- Optional: if you want to ensure the created_at column exists and has a default
-- (uncomment if you need this behavior; many projects already have this column)
-- ALTER TABLE IF EXISTS public.content
--   ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

-- Notes:
-- 1) Supabase SQL editor accepts these statements. Copy/paste and run.
-- 2) After adding these columns, you can re-enable writing `type` and `thumbnail_path`
--    from the admin server (server.js) if you want to persist them automatically.
-- 3) If your Postgres version doesn't support IF NOT EXISTS for ALTER TABLE ADD COLUMN,
--    run a small EXISTS check or use the Supabase SQL editor which usually supports the form above.
