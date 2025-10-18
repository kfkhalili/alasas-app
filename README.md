# Al-Asas: Quran Study Application

Al-Asas is a comprehensive, open-source project designed to help users deepen their understanding and memorization of the Holy Quran. It consists of a Flutter-based mobile application and a Supabase-powered backend. The application provides a variety of interactive quizzes to make learning engaging and effective.

## Project Overview

This repository is a monorepo containing two main components:

1.  **`mobile_app/`**: A cross-platform mobile application built with Flutter. It provides the user interface for taking quizzes, selecting surahs (chapters), and reviewing results.
2.  **`backend/`**: The backend infrastructure, including scripts and serverless functions that support the mobile app. It is responsible for seeding the database and generating quiz content.

The goal of this project is to provide a modern, clean, and effective tool for Quranic studies, suitable for learners at all levels.

## Features

-   **Interactive Quizzes**: Multiple quiz formats to test different aspects of Quranic knowledge.
-   **Focused Study**: Users can select specific surahs to concentrate their learning efforts.
-   **Performance Tracking**: Users receive immediate feedback and can review their answers to track progress.
-   **Cross-Platform**: The Flutter app is designed to run on both Android and iOS.
-   **Scalable Backend**: Utilizes Supabase for a robust and scalable backend infrastructure, including database and serverless Edge Functions.
-   **Bilingual Support**: The quizzes and data include both the original Arabic text and English translations.

## Getting Started

To get the full application running, you will need to set up both the backend and the mobile app.

### 1. Backend Setup

First, set up the backend to populate your database. This step is crucial as the mobile app depends on this data.

-   Navigate to the `backend` directory.
-   Follow the instructions in the `backend/README.md` file to install dependencies, configure your Supabase environment, and run the database seed script.

### 2. Mobile App Setup

Once your backend is seeded with data, you can set up and run the mobile application.

-   Navigate to the `mobile_app` directory.
-   Follow the instructions in the `mobile_app/README.md` file to install Flutter dependencies, connect the app to your Supabase instance, and run it on an emulator or physical device.

## Technology Stack

-   **Frontend (Mobile App)**:
    -   [Flutter](https://flutter.dev/): For building the cross-platform mobile application.
    -   [Dart](https://dart.dev/): The programming language for Flutter.
    -   [Supabase Flutter Client](https://pub.dev/packages/supabase_flutter): For connecting to the Supabase backend.

-   **Backend**:
    -   [Supabase](https://supabase.com/): An open-source Firebase alternative for database, authentication, and serverless functions.
    -   [Node.js](https://nodejs.org/): For running backend scripts.
    -   [TypeScript](https://www.typescriptlang.org/): For writing type-safe backend code.

## Contributing

Contributions are welcome! If you have ideas for new features, bug fixes, or improvements, please feel free to open an issue or submit a pull request.

When contributing, please ensure you follow the existing code style and provide clear descriptions of your changes.

## License

This project is open-source and available under the [MIT License](LICENSE).