-- Create a type for different kinds of questions to ensure data consistency
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'question_type') THEN
        CREATE TYPE question_type AS ENUM (
          'CONCEPT_TO_AYAH',
          'AYAH_TO_MEANING',
          'MEANING_TO_AYAH'
        );
    END IF;
END$$;

-- Create the table for manually created questions
CREATE TABLE IF NOT EXISTS questions (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

  -- The type of question this is
  question_type question_type NOT NULL,

  -- The question itself, e.g., "What is Ayah 2:255 known as?"
  question_text TEXT NOT NULL,

  -- The single correct answer
  correct_answer TEXT NOT NULL,

  -- An array of incorrect answer options
  distractors TEXT[] NOT NULL,

  -- An optional foreign key linking this question to a specific verse
  verse_id INT REFERENCES verses(id) ON DELETE SET NULL,

  -- Timestamps for tracking when the question was added or updated
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);