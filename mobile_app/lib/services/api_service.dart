import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/models/quiz_model.dart';

enum QuizType {
  ayahToNumber,
  nextAyah,
  ayahToMeaning,
  conceptToAyah,
  diacriticQuiz, // --- NEW ---
}

class ApiService {
  final _supabase = Supabase.instance.client;

  Future<Quiz> fetchQuiz(QuizType quizType) async {
    String quizTypeName;

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
      // --- NEW ---
      case QuizType.diacriticQuiz:
        quizTypeName = 'DIACRITIC_QUIZ';
        break;
    }

    try {
      final response = await _supabase.functions.invoke(
        'generate-quiz',
        body: {
          'quizType': quizTypeName,
          'scope': {'type': 'SURAH', 'value': 2},
          'questionCount': 10,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to load quiz: ${response.data}');
      }

      return Quiz.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching quiz: $e');
      throw Exception('Failed to load quiz. Please try again.');
    }
  }
}
