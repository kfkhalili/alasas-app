import { createClient, SupabaseClient } from "@supabase/supabase-js";
import "dotenv/config";
import * as fs from "fs";
import * as path from "path";

// Import the QUL data files
import uthmaniData from "../data/uthmani.json";
import mushafPagesData from "../data/mushaf-pages.json";

// --- Type Definitions ---
// For uthmani.json
interface UthmaniWord {
  id: number;
  surah: string;
  ayah: string;
  word: string;
  location: string;
  text: string;
}

// For mushaf-pages.json
interface MushafPageLine {
  page_number: number;
  line_number: number;
  line_type: string;
  is_centered: number;
  first_word_id: number | null;
  last_word_id: number | null;
  surah_number: number | null;
}

// For DB tables
interface VerseInsert {
  surah_number: number;
  ayah_number: number;
  arabic_text: string;
  english_translation: string;
}
interface VerseRecord {
  id: number;
  surah_number: number;
  ayah_number: number;
}
// This type matches the 'verse_page_update' type in our SQL migration
interface VersePageUpdate {
  verse_id: number;
  p_num: number;
}
interface WordInsert {
  verse_id: number;
  position: number;
  arabic_text: string;
  page_number: number;
  qul_word_id: number;
}
// --- End of Types ---

const BATCH_SIZE = 500;

// --- Batch Insert Utility ---
async function batchInsert<T_Insert, T_Return>(
  supabase: SupabaseClient,
  table: string,
  data: T_Insert[],
  select = "*",
): Promise<T_Return[]> {
  const insertedData: T_Return[] = [];
  for (let i = 0; i < data.length; i += BATCH_SIZE) {
    const batch = data.slice(i, i + BATCH_SIZE);
    const { data: inserted, error } = await supabase
      .from(table)
      .insert(batch)
      .select(select);
    if (error) {
      throw new Error(`Error inserting batch into ${table}: ${error.message}`);
    }
    if (inserted) {
      insertedData.push(...(inserted as T_Return[]));
    }
  }
  return insertedData;
}

// --- PHASE 1: Original Seed Logic (for "Test" Mode) ---
async function seedOriginalVerses(
  supabase: SupabaseClient,
): Promise<Map<string, number>> {
  console.log("--- Phase 1: Seeding original verses (for Test mode) ---");

  console.log("Clearing old data...");
  await supabase.from("quran_words").delete().neq("id", 0);
  await supabase.from("questions").delete().neq("verse_id", 0);
  await supabase.from("verses").delete().neq("id", 0);
  console.log("Old data cleared.");

  // Read file data from /backend/data/
  const quranTextPath = path.join(__dirname, "../data/quran-simple.txt");
  const englishTextPath = path.join(__dirname, "../data/en.sahih.txt");
  const quranLines = fs.readFileSync(quranTextPath, "utf-8").split("\n");
  const englishLines = fs.readFileSync(englishTextPath, "utf-8").split("\n");

  const versesToInsert: VerseInsert[] = [];
  for (let i = 0; i < quranLines.length; i++) {
    const arabicLine = quranLines[i];
    const englishLine = englishLines[i];
    if (!arabicLine || !englishLine) continue;
    const [surah, ayah, arabicText] = arabicLine.split("|");
    const [, , englishText] = englishLine.split("|");
    if (surah && ayah && arabicText && englishText) {
      versesToInsert.push({
        surah_number: parseInt(surah, 10),
        ayah_number: parseInt(ayah, 10),
        arabic_text: arabicText,
        english_translation: englishText,
      });
    }
  }

  console.log(`Inserting ${versesToInsert.length} original verses...`);
  const insertedVerses = await batchInsert<VerseInsert, VerseRecord>(
    supabase,
    "verses",
    versesToInsert,
    "id, surah_number, ayah_number",
  );
  console.log("Original verses inserted.");

  // Create the verse ID map for Phase 2
  const verseIdMap = new Map<string, number>();
  insertedVerses.forEach((v) => {
    verseIdMap.set(`${v.surah_number}:${v.ayah_number}`, v.id);
  });

  console.log("--- Phase 1 Complete ---");
  return verseIdMap;
}

// --- PHASE 2: New QUL Data Seed (for "Memorize" Mode) ---
async function seedQulData(
  supabase: SupabaseClient,
  verseIdMap: Map<string, number>,
) {
  console.log("--- Phase 2: Seeding QUL word data (for Memorize mode) ---");

  // 1. Create Word-to-Page Map from mushaf-pages.json
  console.log("Building word-to-page map...");
  const wordIdToPageMap = new Map<number, number>();
  (mushafPagesData as MushafPageLine[]).forEach((line) => {
    if (line.first_word_id && line.last_word_id) {
      for (let id = line.first_word_id; id <= line.last_word_id; id++) {
        wordIdToPageMap.set(id, line.page_number);
      }
    }
  });
  console.log(`Page map built with ${wordIdToPageMap.size} word entries.`);

  // 2. Prepare 'quran_words' inserts and 'verses' updates
  const wordsToInsert: WordInsert[] = [];
  const versePageMap = new Map<number, number>();
  const allUthmaniWords = Object.values(
    uthmaniData as Record<string, UthmaniWord>,
  );

  console.log(
    `Processing ${allUthmaniWords.length} words from uthmani.json...`,
  );
  allUthmaniWords.forEach((word) => {
    const verseKey = `${word.surah}:${word.ayah}`;
    const verseId = verseIdMap.get(verseKey);
    const pageNumber = wordIdToPageMap.get(word.id);
    const position = parseInt(word.word, 10);

    // Skip words with no verse match or no page match (e.g., '١' markers)
    if (!verseId || !pageNumber || isNaN(position)) {
      return;
    }

    // Add to quran_words batch
    wordsToInsert.push({
      verse_id: verseId,
      position: position,
      arabic_text: word.text,
      page_number: pageNumber,
      qul_word_id: word.id,
    });

    // Store the page number for this verse (first word wins)
    if (position === 1 && !versePageMap.has(verseId)) {
      versePageMap.set(verseId, pageNumber);
    }
  });

  // 3. Batch insert 'quran_words'
  console.log(`Inserting ${wordsToInsert.length} words into quran_words...`);
  await batchInsert<WordInsert, { id: number }>(
    supabase,
    "quran_words",
    wordsToInsert,
    "id",
  );
  console.log("Words inserted.");

  // 4. Batch UPDATE 'verses' with page numbers using RPC
  // This is the FIX
  const versesToUpdate: VersePageUpdate[] = Array.from(
    versePageMap.entries(),
  ).map(([id, page_number]) => ({
    verse_id: id,
    p_num: page_number,
  }));

  console.log(
    `Updating ${versesToUpdate.length} verses with page numbers via RPC...`,
  );

  // We still batch the RPC call just in case the payload is too large
  for (let i = 0; i < versesToUpdate.length; i += BATCH_SIZE) {
    const batch = versesToUpdate.slice(i, i + BATCH_SIZE);

    const { error } = await supabase.rpc("bulk_update_verse_pages", {
      updates: batch,
    });

    if (error) {
      throw new Error(
        `Error calling RPC bulk_update_verse_pages: ${error.message}`,
      );
    }
  }

  console.log("Verse page numbers updated.");
  console.log("--- Phase 2 Complete ---");
}

// --- Main Execution ---
async function main(): Promise<void> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !supabaseKey) {
    throw new Error(
      "SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env file",
    );
  }

  const supabase = createClient(supabaseUrl, supabaseKey);
  console.log("--- Starting Al-Asas Combined Data Seed ---");

  try {
    const verseIdMap = await seedOriginalVerses(supabase);
    await seedQulData(supabase, verseIdMap);
    console.log("--- Combined Seed Complete ---");
  } catch (error) {
    console.error("Error during seeding:", error);
    process.exit(1);
  }
}

main().catch(console.error);
