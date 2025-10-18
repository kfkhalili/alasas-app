# Al-Asas Backend

This directory contains the backend services and scripts for the Al-Asas Quran study application. It includes scripts for database seeding and server-side logic for generating quizzes.

## Overview

The backend is responsible for two main tasks:

1.  **Database Seeding**: Populating the Supabase database with Quranic text and translations from raw data files.
2.  **Quiz Generation**: Providing an API endpoint (via Supabase Edge Functions) that the mobile app can call to get dynamically generated quizzes.

This backend is built using TypeScript and relies on the Supabase platform for database, authentication, and serverless functions.

## Getting Started

Follow these instructions to set up the backend environment and seed your Supabase database.

### Prerequisites

-   **Node.js and npm**: Ensure you have Node.js (version 18 or higher) and npm installed. You can download them from [nodejs.org](https://nodejs.org/).
-   **Supabase Account**: A Supabase project is required. If you don't have one, create it at [supabase.com](https://supabase.com).
-   **Supabase CLI**: The Supabase command-line interface is needed to manage database migrations and deploy Edge Functions. Installation instructions can be found [here](https://supabase.com/docs/guides/cli).

### Setup

1.  **Clone the Repository**:
    If you haven't already, clone the project repository and navigate to the `backend` directory:
    ```bash
    git clone <repository-url>
    cd <repository-directory>/backend
    ```

2.  **Install Dependencies**:
    Install the necessary Node.js packages:
    ```bash
    npm install
    ```

3.  **Set Up Environment Variables**:
    The backend scripts require credentials to connect to your Supabase instance.
    -   Create a file named `.env` in the root of the `backend` directory.
    -   Add your Supabase project URL and a `service_role` key to this file. **Important**: The seed script requires the `service_role` key to bypass Row Level Security (RLS) when clearing and inserting data.
        ```
        SUPABASE_URL=your_supabase_url
        SUPABASE_ANON_KEY=your_supabase_anon_key
        # You can find the service_role key in your Supabase dashboard
        # under Project Settings > API > Project API keys
        ```
    -   **Security Note**: Keep your `service_role` key secret. Do not expose it in client-side applications. It should only be used in secure backend environments.

### Database Seeding

The seed script populates the `verses` table in your Supabase database. This table is the foundation for all quiz generation.

**Database Schema**:
Before running the seed script, ensure your database has a `verses` table with the following schema:

-   `id` (int8, primary key)
-   `created_at` (timestamptz)
-   `surah_number` (int4)
-   `ayah_number` (int4)
-   `arabic_text` (text)
-   `english_translation` (text)

You can use the Supabase dashboard or a migration script to create this table.

**Running the Seed Script**:
Execute the following command from the `backend` directory:

```bash
npx ts-node scripts/seed.ts
```

This script will:
1.  Read the verse data from `data/quran-simple.txt` (Arabic) and `data/en.sahih.txt` (English).
2.  Clear any existing data in the `verses` table.
3.  Insert the combined verses into the table.

The process may take a few moments. Upon completion, you will see a success message in the console.

## Project Structure

-   `data/`: Contains the raw text files for the Quran and its translation.
-   `scripts/`: Holds standalone scripts, such as `seed.ts` for database seeding.
-   `supabase/`: Configuration and code for Supabase-specific features.
    -   `functions/`: Contains the source code for Supabase Edge Functions (e.g., the quiz generator).
-   `package.json`: Defines project metadata and dependencies.
-   `tsconfig.json`: TypeScript compiler configuration.
-   `.env`: (You must create this) Stores your Supabase credentials.