import { createClient, SupabaseClient } from "@supabase/supabase-js";

// --- Unicode Diacritic Constants ---
const FATHA = "\u064E";
const DAMMA = "\u064F";
const KASRA = "\u0650";
const SUKUN = "\u0652";
const DIACRITICS = [FATHA, DAMMA, KASRA, SUKUN];

// (Removed the unused DIACRITIC_REGEX)

// --- Helper Types ---
interface Verse {
  id: number;
  surah_number: number;
  ayah_number: number;
  arabic_text: string;
  english_translation: string;
}

interface ManualQuestion {
  id: number;
  question_text: string;
  correct_answer: string;
  distractors: string[];
  verse_id: number;
}

interface QuizQuestion {
  ayahId: number;
  surahNumber: number;
  ayahNumber: number;
  questionText: string;
  options: string[];
  correctAnswer: string;
}

interface QuizRequest {
  quizType:
    | "AYAH_TO_MEANING"
    | "AYAH_TO_NUMBER"
    | "NEXT_AYAH"
    | "CONCEPT_TO_AYAH"
    | "DIACRITIC_QUIZ";
  scope: {
    type: "SURAH";
    value: number;
  };
  questionCount: number;
}

// --- Helper Functions ---
const shuffleArray = <T>(array: T[]): T[] => {
  const newArray = [...array];
  for (let i = newArray.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
  }
  return newArray;
};

/**
 * Generates a diacritic question from a single verse.
 * FIX: Return type is now the full QuizQuestion
 */
function generateDiacriticQuestion(verse: Verse): QuizQuestion | null {
  const words = verse.arabic_text.trim().split(" ");
  if (words.length < 2) {
    return null;
  }

  const lastWord = words[words.length - 1];
  const questionText = words.slice(0, -1).join(" ");

  let lastDiacritic = "";
  let baseWord = lastWord;

  if (DIACRITICS.includes(lastWord[lastWord.length - 1])) {
    lastDiacritic = lastWord[lastWord.length - 1];
    baseWord = lastWord.substring(0, lastWord.length - 1);
  } else {
    return null;
  }

  const correctAnswer = `${baseWord}${lastDiacritic}`;
  const options = DIACRITICS.map((d) => `${baseWord}${d}`);

  // FIX: This now correctly returns the full object
  return {
    ayahId: verse.id,
    questionText: questionText,
    options: shuffleArray(options),
    correctAnswer: correctAnswer,
    surahNumber: verse.surah_number,
    ayahNumber: verse.ayah_number,
  };
}

// --- Main Server Function ---
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const body: QuizRequest = await req.json();
    const { quizType, scope, questionCount } = body;

    if (!quizType || !scope || !questionCount) {
      throw new Error(
        "Invalid request: missing quizType, scope, or questionCount.",
      );
    }

    const supabase: SupabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: {
            Authorization: req.headers.get("Authorization")!,
          },
        },
      },
    );

    // --- Concept Quiz Logic ---
    if (quizType === "CONCEPT_TO_AYAH") {
      const { data: manualQuestions, error } = await supabase
        .from("questions")
        .select("id, question_text, correct_answer, distractors, verse_id")
        .eq("question_type", "CONCEPT_TO_AYAH")
        .limit(questionCount)
        .returns<ManualQuestion[]>();

      if (error) throw error;
      if (!manualQuestions || manualQuestions.length === 0) {
        throw new Error("No manual questions found.");
      }

      const quizQuestions: QuizQuestion[] = manualQuestions.map((q) => {
        const options = shuffleArray([q.correct_answer, ...q.distractors]);
        return {
          ayahId: q.verse_id,
          surahNumber: 0,
          ayahNumber: 0,
          questionText: q.question_text,
          options: options,
          correctAnswer: q.correct_answer,
        };
      });

      return new Response(JSON.stringify({ questions: quizQuestions }), {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    // --- Diacritic Quiz Logic ---
    if (quizType === "DIACRITIC_QUIZ") {
      const { data: verses, error } = await supabase
        .from("verses")
        .select(
          "id, surah_number, ayah_number, arabic_text, english_translation",
        )
        .eq("surah_number", scope.value)
        .limit(questionCount * 3)
        .returns<Verse[]>();

      if (error) throw error;
      if (!verses || verses.length === 0) {
        throw new Error("No verses found for diacritic quiz.");
      }

      const quizQuestions: QuizQuestion[] = [];
      const shuffledVerses = shuffleArray(verses);

      for (const verse of shuffledVerses) {
        if (quizQuestions.length >= questionCount) {
          break;
        }

        const question = generateDiacriticQuestion(verse);
        if (question) {
          // FIX: 'question' is now the full QuizQuestion type
          quizQuestions.push(question);
        }
      }

      return new Response(JSON.stringify({ questions: quizQuestions }), {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    // --- Existing Dynamic Quiz Logic ---
    const { data: allVerses, error: versesError } = await supabase
      .from("verses")
      .select("id, surah_number, ayah_number, arabic_text, english_translation")
      .eq("surah_number", scope.value)
      .order("ayah_number", { ascending: true })
      .returns<Verse[]>();

    // FIX: Split the checks to satisfy the linter
    if (versesError) throw versesError;
    if (!allVerses || allVerses.length < 4) {
      throw new Error(
        "Database query failed or not enough verses (need at least 4).",
      );
    }

    let quizQuestions: QuizQuestion[] = [];
    const allVersesShuffled = shuffleArray(allVerses);

    switch (quizType) {
      case "AYAH_TO_MEANING": {
        const selectedVerses = allVersesShuffled.slice(0, questionCount);
        quizQuestions = selectedVerses.map((verse) => {
          const distractors = allVersesShuffled
            .filter((v) => v.id !== verse.id)
            .slice(0, 3)
            .map((d) => d.english_translation);
          const options = shuffleArray([
            verse.english_translation,
            ...distractors,
          ]);
          return {
            ayahId: verse.id,
            surahNumber: verse.surah_number,
            ayahNumber: verse.ayah_number,
            questionText: verse.arabic_text,
            options: options,
            correctAnswer: verse.english_translation,
          };
        });
        break;
      }
      case "AYAH_TO_NUMBER": {
        const selectedVerses = allVersesShuffled.slice(0, questionCount);
        quizQuestions = selectedVerses.map((verse) => {
          const correctAnswer = `${verse.surah_number}:${verse.ayah_number}`;
          const distractors = allVersesShuffled
            .filter((v) => v.id !== verse.id)
            .slice(0, 3)
            .map((d) => `${d.surah_number}:${d.ayah_number}`);
          const options = shuffleArray([correctAnswer, ...distractors]);
          return {
            ayahId: verse.id,
            surahNumber: verse.surah_number,
            ayahNumber: verse.ayah_number,
            questionText: verse.arabic_text,
            options: options,
            correctAnswer: correctAnswer,
          };
        });
        break;
      }
      case "NEXT_AYAH": {
        const validIndices = Array.from(Array(allVerses.length - 1).keys());
        const selectedIndices = shuffleArray(validIndices).slice(
          0,
          questionCount,
        );
        quizQuestions = selectedIndices.map((index) => {
          const currentVerse = allVerses[index];
          const nextVerse = allVerses[index + 1];
          const correctAnswer = nextVerse.arabic_text;
          const distractors = allVersesShuffled
            .filter((v) => v.id !== currentVerse.id && v.id !== nextVerse.id)
            .slice(0, 3)
            .map((d) => d.arabic_text);
          const options = shuffleArray([correctAnswer, ...distractors]);
          return {
            ayahId: currentVerse.id,
            surahNumber: currentVerse.surah_number,
            ayahNumber: currentVerse.ayah_number,
            questionText: currentVerse.arabic_text,
            options: options,
            correctAnswer: correctAnswer,
          };
        });
        break;
      }
    }

    return new Response(JSON.stringify({ questions: quizQuestions }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    const errorMessage = error instanceof Error
      ? error.message
      : "An unknown error occurred";
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
