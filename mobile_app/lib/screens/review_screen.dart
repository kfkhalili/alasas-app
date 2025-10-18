import 'package:flutter/material.dart';
import 'package:mobile_app/models/question_model.dart';

/// A screen that allows users to review their answers after completing a quiz.
///
/// It displays each question, the user's answer, and the correct answer,
/// highlighting whether the user's answer was correct or not.
class ReviewScreen extends StatelessWidget {
  /// The list of questions from the quiz.
  final List<Question> questions;

  /// The list of answers the user provided.
  final List<String> userAnswers;

  /// Creates a [ReviewScreen].
  ///
  /// - [questions]: The list of questions to be reviewed.
  /// - [userAnswers]: The corresponding list of user-submitted answers.
  const ReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Answers')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswer = userAnswers[index];
          final isCorrect = userAnswer == question.correctAnswer;

          final bool isQuestionArabic = question.questionText.contains(
            RegExp(r'[\u0600-\u06FF]'),
          );
          final bool isAnswerArabic = userAnswer.contains(
            RegExp(r'[\u0600-\u06FF]'),
          );
          final bool isCorrectAnswerArabic = question.correctAnswer.contains(
            RegExp(r'[\u0600-\u06FF]'),
          );

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question.questionText}',
                    textDirection: isQuestionArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    // --- APPLY FONT HERE ---
                    style: TextStyle(
                      fontFamily: isQuestionArabic ? 'NotoNaskhArabic' : null,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Your answer: $userAnswer',
                    textDirection: isAnswerArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    // --- APPLY FONT HERE ---
                    style: TextStyle(
                      fontFamily: isAnswerArabic ? 'NotoNaskhArabic' : null,
                      fontSize: 16,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (!isCorrect)
                    Text(
                      'Correct answer: ${question.correctAnswer}',
                      textDirection: isCorrectAnswerArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      // --- APPLY FONT HERE ---
                      style: TextStyle(
                        fontFamily: isCorrectAnswerArabic
                            ? 'NotoNaskhArabic'
                            : null,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
