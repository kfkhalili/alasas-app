import 'package:flutter/material.dart';
import 'package:mobile_app/models/question_model.dart';
import 'package:mobile_app/models/quiz_model.dart';
import 'package:mobile_app/screens/results_screen.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  int _score = 0;
  final List<String> _userAnswers = [];

  Question get _currentQuestion => widget.quiz.questions[_currentIndex];

  void _handleAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _userAnswers.add(answer);

      if (answer == _currentQuestion.correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < widget.quiz.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswer = null;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              score: _score,
              questions: widget.quiz.questions,
              userAnswers: _userAnswers,
            ),
          ),
        );
      }
    });
  }

  // --- NEW: Theme-aware color logic ---
  Color _getButtonColor(BuildContext context, String option) {
    final theme = Theme.of(context);

    if (!_isAnswered) {
      // Use a neutral theme color
      return theme.colorScheme.secondaryContainer;
    }
    if (option == _currentQuestion.correctAnswer) {
      return Colors.green; // Correct
    }
    if (option == _selectedAnswer) {
      return theme.colorScheme.error; // Incorrect
    }
    // Default for unselected, answered options
    return theme.colorScheme.secondaryContainer.withOpacity(0.5);
  }

  Color _getTextColor(BuildContext context, String option) {
    final theme = Theme.of(context);

    if (!_isAnswered) {
      // Text color for the neutral button
      return theme.colorScheme.onSecondaryContainer;
    }
    if (option == _currentQuestion.correctAnswer) {
      return Colors.white; // Text on green button
    }
    if (option == _selectedAnswer) {
      return theme.colorScheme.onError; // Text on red button
    }
    // Text for unselected, answered options
    return theme.colorScheme.onSecondaryContainer.withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isQuestionArabic = _currentQuestion.questionText.contains(
      RegExp(r'[\u0600-\u06FF]'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1} of ${widget.quiz.questions.length}',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // --- NEW: Use theme color instead of Colors.white ---
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _currentQuestion.questionText,
                  textAlign: isQuestionArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  textDirection: isQuestionArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: isQuestionArabic ? 'NotoNaskhArabic' : null,
                    fontSize: isQuestionArabic ? 24 : 20,
                    height: 1.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ..._currentQuestion.options.map((option) {
                final bool isArabic = option.contains(
                  RegExp(r'[\u0600-\u06FF]'),
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: _isAnswered ? null : () => _handleAnswer(option),
                    style: ElevatedButton.styleFrom(
                      // --- NEW: Pass context to get theme colors ---
                      backgroundColor: _getButtonColor(context, option),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: isArabic ? 'NotoNaskhArabic' : null,
                        fontSize: 18,
                        // --- NEW: Pass context to get theme colors ---
                        color: _getTextColor(context, option),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
