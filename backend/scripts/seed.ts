import { createClient, SupabaseClient } from "@supabase/supabase-js";
import fs from "node:fs/promises";
import path from "node:path";
import "dotenv/config";

// --- Pure Functions for Data Transformation ---

/**
 * Represents the structure of a single verse to be inserted into the database.
 */
interface Verse {
  surah_number: number;
  ayah_number: number;
  arabic_text: string;
  english_translation: string;
}

/**
 * Parses a single line of a verse file.
 *
 * @param {string} line - A single line from a verse file.
 * @returns {{ key: string, text: string } | null} An object with key and text, or null if the line is invalid.
 */
const parseVerseLine = (line: string): { key: string; text: string } | null => {
  const trimmedLine = line.trim();
  if (trimmedLine.length === 0 || trimmedLine.startsWith("#")) {
    return null;
  }

  const [surah, ayah, ...textParts] = trimmedLine.split("|");
  return {
    key: `${surah}:${ayah}`,
    text: textParts.join("|").trim(),
  };
};

/**
 * Combines verse maps into an array of Verse objects.
 *
 * @param {Map<string, string>} arabicMap - A map of Arabic verses.
 * @param {Map<string, string>} englishMap - A map of English verses.
 * @returns {Verse[]} An array of combined Verse objects.
 */
const combineVerseMaps = (
  arabicMap: Map<string, string>,
  englishMap: Map<string, string>
): Verse[] => {
  return Array.from(arabicMap.keys()).map((key) => {
    const [surah, ayah] = key.split(":").map(Number);
    const arabicText = arabicMap.get(key) ?? "";
    const englishTranslation = englishMap.get(key) ?? "";

    return {
      surah_number: surah,
      ayah_number: ayah,
      arabic_text: arabicText,
      english_translation: englishTranslation,
    };
  });
};

// --- Impure Functions for Side Effects (File & DB I/O) ---

/**
 * Creates and configures a Supabase client.
 *
 * @returns {SupabaseClient} An initialized Supabase client instance.
 * @throws {Error} If Supabase URL or key is not provided.
 */
const createSupabaseClient = (): SupabaseClient => {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    throw new Error("Supabase URL and Key must be provided in .env file.");
  }
  return createClient(supabaseUrl, supabaseKey);
};

/**
 * Parses a text file containing Quran verses into a map.
 *
 * @param {string} fileName - The name of the file to parse.
 * @returns {Promise<Map<string, string>>} A promise that resolves to a map of verses.
 */
const parseVerseFile = async (
  fileName: string
): Promise<Map<string, string>> => {
  const filePath = path.join(__dirname, "..", "data", fileName);
  const fileContent = await fs.readFile(filePath, "utf-8");

  const verses = fileContent
    .split("\n")
    .map(parseVerseLine)
    .filter((v): v is { key: string; text: string } => v !== null);

  return new Map(verses.map((v) => [v.key, v.text]));
};

/**
 * Clears the 'verses' table in the database.
 *
 * @param {SupabaseClient} supabase - The Supabase client.
 */
const clearVerses = async (supabase: SupabaseClient): Promise<void> => {
  await supabase.from("verses").delete().neq("id", 0);
};

/**
 * Inserts verses into the 'verses' table.
 *
 * @param {SupabaseClient} supabase - The Supabase client.
 * @param {Verse[]} verses - An array of verses to insert.
 * @throws {Error} If the insertion fails.
 */
const insertVerses = async (
  supabase: SupabaseClient,
  verses: Verse[]
): Promise<void> => {
  const { error } = await supabase.from("verses").insert(verses);
  if (error) {
    throw new Error(`Failed to insert verses: ${error.message}`);
  }
};

// --- Main Execution ---

/**
 * Main function to seed the database.
 */
const seedDatabase = async (): Promise<void> => {
  console.log("Starting database seed...");

  try {
    const supabase = createSupabaseClient();

    const [arabicMap, englishMap] = await Promise.all([
      parseVerseFile("quran-simple.txt"),
      parseVerseFile("en.sahih.txt"),
    ]);
    console.log(
      `Parsed ${arabicMap.size} Arabic and ${englishMap.size} English verses.`
    );

    const verses = combineVerseMaps(arabicMap, englishMap);
    console.log(`Preparing to insert ${verses.length} combined verses...`);

    await clearVerses(supabase);
    console.log("Cleared existing verses from the table.");

    await insertVerses(supabase, verses);
    console.log(
      `Successfully seeded ${verses.length} verses into the database.`
    );
  } catch (error) {
    console.error("Database seeding failed:", error);
    process.exit(1);
  }
};

seedDatabase();
