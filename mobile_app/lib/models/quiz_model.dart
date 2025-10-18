import 'package:mobile_app/models/question_model.dart';

/// Represents a quiz, which consists of a list of [Question]s.
class Quiz {
  /// The list of questions in the quiz.
  final List<Question> questions;

  /// Creates a new [Quiz] instance.
  ///
  /// - [questions]: The list of questions for the quiz.
  Quiz({required this.questions});

  /// Creates a [Quiz] instance from a JSON object.
  ///
  /// This factory constructor parses a JSON map to create a [Quiz] object.
  /// It expects a 'questions' key with a list of question JSON objects.
  ///
  /// - [json]: The JSON map representing the quiz.
  factory Quiz.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'] as List;
    final questions = questionsList
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    return Quiz(questions: questions);
  }
}
