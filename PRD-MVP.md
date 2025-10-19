## Al-Asas Quran Knowledge App - MVP PRD

**Version:** 1.0
**Date:** October 19, 2025

### 1. Introduction & Objective

**Al-Asas** is a mobile application designed to help users test and reinforce their knowledge of the Holy Qur'an in a respectful, non-competitive manner. This document outlines the requirements for the Minimum Viable Product (MVP). The primary goal of the MVP is to provide a functional quiz experience focused initially on testing knowledge related to specific Surahs, addressing key user-identified challenges.

---

### 2. Goals (MVP)

- Provide a focused quiz experience based on specific Surahs.
- Offer multiple quiz types targeting different knowledge areas (meaning, location, sequence, concepts, verse endings).
- Implement secure data fetching from a backend.
- Deliver immediate feedback during the quiz.
- Allow users to review their answers after completing a quiz.
- Support both light and dark modes based on device settings.
- Use a clear and aesthetically pleasing Arabic font.
- Allow users to select the Surah they wish to be quizzed on.

---

### 3. Target User

The initial primary user is the developer themself, focusing on personal learning and memorization challenges. The MVP aims to solve these specific user needs first.

---

### 4. Tech Stack

- **Backend:** Supabase Platform
  - Database: PostgreSQL
  - API: Supabase Edge Function (Deno/TypeScript)
- **Mobile App:** Flutter (iOS & Android)
- **Authentication:** Supabase Auth (Anonymous sign-in for MVP)
- **Configuration:** `flutter_dotenv` for managing API keys.

---

### 5. Data Sources & Schema

- **Sources:**
  - `quran-simple.txt`: Arabic text with full tashkeel.
  - `en.sahih.txt`: Sahih International English translation.
  - `surah_names.json`: Derived from `quran-data.js`, mapping Surah numbers to transliterated names (bundled as a Flutter asset).
- **Database Schema (Supabase/PostgreSQL):**
  - `verses`: Stores individual ayah data.
    - `id` (INT, PK, Auto-increment)
    - `surah_number` (INT, NOT NULL)
    - `ayah_number` (INT, NOT NULL)
    - `arabic_text` (TEXT, NOT NULL)
    - `english_translation` (TEXT, NOT NULL)
    - `UNIQUE(surah_number, ayah_number)` constraint.
    - Indexed on `surah_number`.
  - `questions`: Stores manually created concept questions.
    - `id` (BIGINT, PK, Auto-increment)
    - `question_type` (ENUM `question_type`, NOT NULL - e.g., 'CONCEPT_TO_AYAH')
    - `question_text` (TEXT, NOT NULL)
    - `correct_answer` (TEXT, NOT NULL)
    - `distractors` (TEXT[], NOT NULL - PostgreSQL array)
    - `verse_id` (INT, FK referencing `verses.id` ON DELETE SET NULL)
    - `created_at`, `updated_at` (TIMESTAMPTZ)

---

### 6. Backend Requirements (`generate-quiz` Edge Function)

- **Endpoint:** Accessed via Supabase function invocation.
- **Method:** `POST`
- **Request Body:** JSON object containing:
  - `quizType` (String enum: "AYAH_TO_MEANING" for **Meaning Match**, "AYAH_TO_NUMBER" for **Verse Location**, "NEXT_AYAH" for **Sequence Recall**, "CONCEPT_TO_AYAH" for **Concept Check**, "DIACRITIC_QUIZ" for **Verse Endings**)
  - `surahNumber` (Integer: 1-114)
  - `questionCount` (Integer: currently fixed at 3 for MVP testing, configurable)
- **Logic:**
  - Validates input (`quizType`, `surahNumber`, `questionCount`).
  - Connects to Supabase DB using user's Authorization header.
  - **Concept Check:** Fetches relevant `verse_ids` for the `surahNumber`, then queries the `questions` table filtered by `verse_id`.
  - **Verse Endings:** Fetches verses for `surahNumber`, performs Unicode parsing to isolate the last word, removes its final diacritic for the question text, and generates options with different final diacritics. Skips verses unsuitable for this format.
  - **Other Quizzes:** Fetches verses for `surahNumber` from the `verses` table. Generates questions and distractors dynamically based on `quizType` (meaning, number, or next verse).
  - Handles errors gracefully (e.g., not enough verses, invalid input).
- **Response:** JSON object `{ "questions": [QuizQuestion] }` or `{ "error": "message" }`.
  - `QuizQuestion`: `{ ayahId, surahNumber, ayahNumber, questionText, options[], correctAnswer }`

---

### 7. Mobile App Requirements (Flutter)

- **Initialization:**
  - Loads Supabase URL/Key from `.env` file via `flutter_dotenv`.
  - Initializes `SupabaseFlutter`.
  - Performs anonymous sign-in on startup.
- **Core Screens:**
  - **`HomeScreen`:**
    - Displays the currently selected Surah name (loaded from `surah_names.json`).
    - Provides a "Change" button navigating to `SelectSurahScreen`.
    - Lists available quiz types with clear names: "**Meaning Match**", "**Verse Location**", "**Sequence Recall**", "**Concept Check**", "**Verse Endings**".
    - Disables buttons and shows a blur overlay while loading quiz data.
    - Uses `SharedAxisTransition` to navigate to `QuizScreen`.
    - No `AppBar`.
  - **`SelectSurahScreen`:**
    - Displays a searchable, scrollable list of all 114 Surahs (Number + Name).
    - Highlights the currently selected Surah.
    - Returns the selected Surah number to `HomeScreen` when an item is tapped.
  - **`QuizScreen`:**
    - Receives `Quiz` object.
    - Displays one `Question` at a time.
    - `AppBar` shows progress (e.g., "Question 1 of 3").
    - Displays `questionText` (handles RTL/LTR, uses Noto Naskh Arabic font).
    - Displays `options` as tappable `ElevatedButton`s.
    - Provides immediate visual feedback on tap (green/red button colors).
    - Disables options after selection.
    - Automatically advances to the next question after a 1.5s delay.
    - Resets scroll position to the top for each new question.
    - Uses `AnimatedSwitcher` with `SlideTransition` between questions.
    - Tracks score and user answers.
    - Navigates to `ResultsScreen` upon completion.
  - **`ResultsScreen`:**
    - Receives score, list of questions, and user answers.
    - Displays the final score (e.g., "2/3").
    - Provides a "Review Answers" button navigating to `ReviewScreen`.
    - Provides a "Back to Home" button.
  - **`ReviewScreen`:**
    - Displays a `ListView` of all questions from the completed quiz.
    - For each question:
      - Shows question number and verse reference (e.g., "Verse 2:158").
      - Shows the `questionText` (using custom font, handling RTL/LTR).
      - Displays all original `options`.
      - Clearly highlights the correct answer (e.g., green background/icon).
      - Clearly highlights the user's answer if incorrect (e.g., red icon).
- **Models:** `question_model.dart`, `quiz_model.dart` with `fromJson` constructors.
- **Service:** `api_service.dart` encapsulates calling the `generate-quiz` Edge Function.
- **Styling:**
  - Uses `MaterialApp` with `ThemeData` based on `ColorScheme.fromSeed(Colors.green)`.
  - Respects system light/dark mode (`themeMode: ThemeMode.system`).
  - Uses `NotoNaskhArabic` font for Arabic text, loaded from assets.
  - Uses theme-aware colors (`colorScheme`) instead of hardcoded colors where appropriate.

---

### 8. Security Considerations

- **Database:** Row Level Security (RLS) is enabled on the `verses` table, allowing `SELECT` only for `authenticated` users. Policy added for `questions` table as well.
- **API Keys:** Supabase URL and Anon Key are stored in `.env` and loaded via `flutter_dotenv`, not committed to source control.
- **Authentication:** Anonymous sign-in provides the `authenticated` status required by RLS for the MVP.

---

### 9. Future Considerations (Out of Scope for MVP)

- Persistent user progress tracking (requires user accounts).
- Displaying completion status on `SelectSurahScreen`.
- More advanced quiz types using QUL word-by-word data.
- Internationalization (i18n) for UI text.
- Audio integration.
- Splash screen and App Icon.
- More sophisticated Surah/Juz'/Page range selection UI.
- Refined error handling and user feedback.
- App Store preparation.
