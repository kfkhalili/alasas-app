import 'package:flutter/material.dart';
import 'package:mobile_app/models/question_model.dart';
import 'package:mobile_app/screens/review_screen.dart'; // Import new screen

/// A screen that displays the user's quiz results.
///
/// This screen shows the final score and provides options to review the answers
/// or return to the home screen.
class ResultsScreen extends StatelessWidget {
  /// The number of correctly answered questions.
  final int score;

  /// The list of all questions from the quiz.
  final List<Question> questions;

  /// The list of answers provided by the user.
  final List<String> userAnswers;

  /// Creates a [ResultsScreen].
  ///
  /// - [score]: The user's final score.
  /// - [questions]: The list of questions that were in the quiz.
  /// - [userAnswers]: The list of answers the user selected.
  const ResultsScreen({
    super.key,
    required this.score,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'You Scored',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '$score / ${questions.length}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                // --- NEW: Wire up the button ---
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(
                        questions: questions,
                        userAnswers: userAnswers,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Review Answers'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
