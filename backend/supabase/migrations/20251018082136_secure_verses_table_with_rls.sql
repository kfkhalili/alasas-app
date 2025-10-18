-- 1. Enable Row Level Security (RLS) on the 'verses' table.
-- This immediately blocks all public access.
ALTER TABLE verses ENABLE ROW LEVEL SECURITY;

-- 2. Create a policy to "Allow authenticated users to read".
-- This opens access ONLY to users who are logged in (authenticated).
CREATE POLICY "Allow authenticated users to read verses"
ON verses
FOR SELECT
TO authenticated
USING (true);