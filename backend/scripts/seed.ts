import { createClient, SupabaseClient } from "@supabase/supabase-js";
import fs from "node:fs/promises";
import path from "node:path";
import "dotenv/config";

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
 * Creates and configures a Supabase client.
 *
 * This function reads the Supabase URL and anonymous key from the environment
 * variables (`.env` file) and uses them to initialize a Supabase client.
 *
 * @returns {SupabaseClient} An initialized Supabase client instance.
 * @throws {Error} If the Supabase URL or key is not found in the environment variables.
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
 * Each line in the file is expected to be in the format "surah|ayah|text".
 * This function reads the file, splits it into lines, and parses each line
 * to create a map where the key is "surah:ayah" and the value is the verse text.
 * It ignores empty lines and lines starting with '#'.
 *
 * @param {string} fileName - The name of the file to parse, located in the `../data` directory.
 * @returns {Promise<Map<string, string>>} A promise that resolves to a map of verses.
 */
const parseVerseFile = async (
  fileName: string
): Promise<Map<string, string>> => {
  const filePath = path.join(__dirname, "..", "data", fileName);
  const fileContent = await fs.readFile(filePath, "utf-8");

  const verses = fileContent
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"))
    .map((line) => {
      const [surah, ayah, ...textParts] = line.split("|");
      return {
        key: `${surah}:${ayah}`,
        text: textParts.join("|").trim(),
      };
    });

  return new Map(verses.map((v) => [v.key, v.text]));
};

/**
 * Seeds the Supabase database with Quran verses.
 *
 * This is the main function of the script. It performs the following steps:
 * 1. Creates a Supabase client.
 * 2. Parses both the Arabic and English verse files into maps.
 * 3. Combines the data from both maps into an array of `Verse` objects.
 * 4. Deletes all existing data from the `verses` table.
 * 5. Inserts the new combined verse data into the `verses` table.
 *
 * @returns {Promise<void>} A promise that resolves when the database has been successfully seeded.
 * @throws {Error} If the database insertion fails.
 */
const seedDatabase = async (): Promise<void> => {
  console.log("Starting database seed...");

  const supabase = createSupabaseClient();

  const [arabicMap, englishMap] = await Promise.all([
    parseVerseFile("quran-simple.txt"),
    parseVerseFile("en.sahih.txt"),
  ]);

  console.log(
    `Parsed ${arabicMap.size} Arabic and ${englishMap.size} English verses.`
  );

  const verses: Verse[] = Array.from(arabicMap.keys()).map((key) => {
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

  console.log(`Preparing to insert ${verses.length} combined verses...`);

  await supabase.from("verses").delete().neq("id", 0);
  console.log("Cleared existing verses from the table.");

  const { error } = await supabase.from("verses").insert(verses);

  if (error) {
    throw new Error(`Failed to insert verses: ${error.message}`);
  }

  console.log(`Successfully seeded ${verses.length} verses into the database.`);
};

seedDatabase().catch((error) => {
  console.error("Database seeding failed:", error);
  process.exit(1);
});
