import { createClient, SupabaseClient } from "@supabase/supabase-js";
import fs from "node:fs/promises";
import path from "node:path";
import "dotenv/config";

interface Verse {
  surah_number: number;
  ayah_number: number;
  arabic_text: string;
  english_translation: string;
}

const createSupabaseClient = (): SupabaseClient => {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    throw new Error("Supabase URL and Key must be provided in .env file.");
  }
  return createClient(supabaseUrl, supabaseKey);
};

const parseVerseFile = async (
  fileName: string
): Promise<Map<string, string>> => {
  // This path is now correctly relative to the location of this script file.
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
