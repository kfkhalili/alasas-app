-- 1. Enable Row Level Security (RLS) on the 'verses' table
-- This locks down the table so that policies must grant access.
ALTER TABLE public.verses ENABLE ROW LEVEL SECURITY;

-- 2. Create a policy to "Allow authenticated users to read".
-- This opens access ONLY to users who are logged in (authenticated).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE policyname = 'Allow authenticated users to read verses'
    AND tablename = 'verses'
  ) THEN
    CREATE POLICY "Allow authenticated users to read verses"
      ON public.verses FOR SELECT
      TO authenticated
      USING (true);
  END IF;
END $$;

-- Optional: If you need to restrict INSERT/UPDATE/DELETE,
-- add policies for those actions here, likely restricted to `service_role`.
-- e.g., CREATE POLICY "Allow admin full access" ON public.verses FOR ALL TO service_role;