import 'package:mobile_app/models/question_model.dart';

class Quiz {
  final List<Question> questions;

  Quiz({required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'] as List;
    final questions = questionsList
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    return Quiz(questions: questions);
  }
}
