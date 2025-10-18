CREATE TABLE IF NOT EXISTS verses (
  id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  surah_number INT NOT NULL,
  ayah_number INT NOT NULL,
  arabic_text TEXT NOT NULL,
  english_translation TEXT NOT NULL,
  UNIQUE(surah_number, ayah_number)
);

CREATE INDEX IF NOT EXISTS idx_surah ON verses(surah_number);