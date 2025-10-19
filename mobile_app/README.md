# Alasas - Quran Study Mobile App

Alasas is a Flutter-based mobile application designed to help users deepen their knowledge and memorization of the Quran through a series of interactive quizzes. The app connects to a Supabase backend to fetch quiz data and provides a clean, user-friendly interface for an engaging learning experience.

## Features

- **Multiple Quiz Modes**: Test your knowledge with various quiz formats, including:
  - **Meaning Match**: Match a verse to its English translation.
  - **Verse Location**: Identify the surah and verse number of a given verse.
  - **Sequence Recall**: Determine the next verse in a sequence.
  - **Concept Check**: Connect a Quranic concept to its corresponding verse.
  - **Verse Endings**: Test your knowledge of verse endings (diacritics).
- **Surah Selection**: Choose any surah of the Quran to focus your study session.
- **Interactive Quiz Interface**: A smooth and responsive UI for answering questions.
- **Results and Review**: Get immediate feedback on your score and review your answers to learn from mistakes.
- **Dynamic Theming**: Supports both light and dark modes based on your system settings.
- **Supabase Integration**: Powered by a Supabase backend for generating quizzes and managing data.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- **Flutter SDK**: Ensure you have Flutter installed. For installation instructions, see the [official Flutter documentation](https://docs.flutter.dev/get-started/install).
- **Supabase Account**: You will need a Supabase project to act as the backend. You can create one for free at [supabase.com](https://supabase.com).

### Setup

1.  **Clone the Repository**:

    ```bash
    git clone <repository-url>
    cd <repository-directory>/mobile_app
    ```

2.  **Install Dependencies**:
    Run the following command to fetch all the necessary Flutter packages:

    ```bash
    flutter pub get
    ```

3.  **Set Up Environment Variables**:
    The app requires credentials to connect to your Supabase instance.

    - Create a file named `.env` in the root of the `mobile_app` directory.
    - Add your Supabase URL and Anon Key to this file:
      ```
      SUPABASE_URL=your_supabase_url
      SUPABASE_ANON_KEY=your_supabase_anon_key
      ```
    - You can find these credentials in your Supabase project's dashboard under `Project Settings > API`.

4.  **Run the Backend Seed Script**:
    The mobile app depends on data being present in your Supabase database. Make sure you have run the seed script located in the `backend` directory of this repository. Follow the instructions in the `backend/README.md` to set up and seed the database.

5.  **Run the Application**:
    Connect a device or start an emulator/simulator, and then run the app with the following command:
    ```bash
    flutter run
    ```

## How to Use

1.  **Home Screen**: Upon launching the app, you'll see the home screen. The default surah for study is Al-Baqarah.
2.  **Change Surah**: Tap the "Change" button to open the Surah selection screen. Here, you can search for and select a different surah to study.
3.  **Select a Quiz**: Choose one of the quiz modes from the list on the home screen.
4.  **Take the Quiz**: Answer the questions presented. The interface will provide immediate feedback on whether your answer was correct.
5.  **View Results**: After completing the quiz, you will see your score.
6.  **Review Answers**: From the results screen, you can navigate to a review screen to see all the questions, your answers, and the correct answers.

## Project Structure

- `lib/`: Contains all the Dart source code.
  - `main.dart`: The entry point of the application.
  - `models/`: Data models for the application (e.g., `Quiz`, `Question`).
  - `screens/`: UI widgets for each screen of the app (e.g., `HomeScreen`, `QuizScreen`).
  - `services/`: Service classes that handle business logic, like API communication (`ApiService`).
- `assets/`: Static assets used by the app.
  - `data/`: JSON data files (e.g., surah names).
  - `fonts/`: Custom fonts, such as `NotoNaskhArabic`.
- `pubspec.yaml`: The project's configuration file, including dependencies.
- `.env`: (You must create this) Contains environment variables for Supabase credentials.
