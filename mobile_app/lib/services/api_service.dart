import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/models/quiz_model.dart';

// Enum defining the different types of quizzes available
enum QuizType {
  ayahToNumber,
  nextAyah,
  ayahToMeaning,
  conceptToAyah,
  diacriticQuiz,
}

class ApiService {
  final _supabase = Supabase.instance.client;

  // Fetches a quiz from the backend based on the type and Surah number
  Future<Quiz> fetchQuiz(QuizType quizType, int surahNumber) async {
    String quizTypeName;

    // Map the enum to the string expected by the backend
    switch (quizType) {
      case QuizType.ayahToNumber:
        quizTypeName = 'AYAH_TO_NUMBER';
        break;
      case QuizType.nextAyah:
        quizTypeName = 'NEXT_AYAH';
        break;
      case QuizType.ayahToMeaning:
        quizTypeName = 'AYAH_TO_MEANING';
        break;
      case QuizType.conceptToAyah:
        quizTypeName = 'CONCEPT_TO_AYAH';
        break;
      case QuizType.diacriticQuiz:
        quizTypeName = 'DIACRITIC_QUIZ';
        break;
    }

    try {
      // Invoke the Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'generate-quiz',
        body: {
          'quizType': quizTypeName,
          'surahNumber': surahNumber, // Pass the selected Surah
          'questionCount': 3, // Keep question count fixed for now
        },
      );

      // --- Robust Error Handling ---
      // Check for explicit errors returned by the function
      if (response.data != null && response.data['error'] != null) {
        throw Exception('Backend error: ${response.data['error']}');
      }
      // Check for non-200 HTTP status codes
      if (response.status != 200) {
        throw Exception(
          'Failed to load quiz (Status ${response.status}): ${response.data}',
        );
      }
      // Check if the expected data structure is present
      if (response.data == null || response.data['questions'] == null) {
        throw Exception('Received invalid data structure from backend.');
      }
      // --- End Error Handling ---

      // Parse the successful response using the Quiz model
      return Quiz.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Log the error and re-throw a user-friendly message
      debugPrint('Error fetching quiz: $e');
      // Improve user message slightly
      throw Exception(
        'Failed to load quiz. Please check your connection and try again.',
      );
    }
  }
}
