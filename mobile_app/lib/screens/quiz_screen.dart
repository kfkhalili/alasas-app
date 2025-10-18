import 'package:flutter/material.dart';
import 'package:mobile_app/models/question_model.dart';
import 'package:mobile_app/models/quiz_model.dart';
import 'package:mobile_app/screens/results_screen.dart';

/// A screen that presents a quiz to the user, one question at a time.
///
/// This widget manages the display of questions, handles user input, and
/// transitions between questions. Once the quiz is complete, it navigates
/// to the [ResultsScreen].
class QuizScreen extends StatefulWidget {
  /// The quiz data to be presented.
  final Quiz quiz;

  /// Creates a [QuizScreen].
  ///
  /// - [quiz]: The quiz object containing the list of questions.
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

/// The state for the [QuizScreen].
///
/// Handles the quiz logic, such as tracking the current question index,
/// the user's score, selected answers, and the UI state for feedback.
class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  int _score = 0;
  final List<String> _userAnswers = [];

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// A getter for the currently displayed question.
  Question get _currentQuestion => widget.quiz.questions[_currentIndex];

  /// Processes the user's selected answer.
  ///
  /// This method updates the state to reflect the user's choice, increments the
  /// score if the answer is correct, and records the user's answer. It then
  /// triggers a delayed transition to the next question or to the results screen.
  ///
  /// - [answer]: The answer option selected by the user.
  void _handleAnswer(String answer) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _userAnswers.add(answer);

      if (answer == _currentQuestion.correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) {
        return;
      }

      if (_currentIndex < widget.quiz.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswer = null;
          _scrollController.jumpTo(0.0); // Instantly jump to top
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

  /// Determines the background color of an answer button based on its state.
  ///
  /// - If the question has not been answered, returns the default color.
  /// - If the answer is correct, returns green.
  /// - If the answer is incorrect and was selected by the user, returns red.
  /// - Otherwise, returns a muted/disabled color.
  ///
  /// - [context]: The build context.
  /// - [option]: The answer option associated with the button.
  Color _getButtonColor(BuildContext context, String option) {
    final theme = Theme.of(context);
    if (!_isAnswered) {
      return theme.colorScheme.secondaryContainer;
    }
    if (option == _currentQuestion.correctAnswer) {
      return Colors.green;
    }
    if (option == _selectedAnswer) {
      return theme.colorScheme.error;
    }
    return theme.colorScheme.secondaryContainer.withAlpha(128);
  }

  /// Determines the text color of an answer button based on its state.
  ///
  /// This ensures text is legible against the button's background color, which
  /// is determined by [_getButtonColor]. For example, it returns white text for
  /// correct (green) answers.
  ///
  /// - [context]: The build context.
  /// - [option]: The answer option associated with the button.
  Color _getTextColor(BuildContext context, String option) {
    final theme = Theme.of(context);
    if (!_isAnswered) {
      return theme.colorScheme.onSecondaryContainer;
    }
    if (option == _currentQuestion.correctAnswer) {
      return Colors.white;
    }
    if (option == _selectedAnswer) {
      return theme.colorScheme.onError;
    }
    return theme.colorScheme.onSecondaryContainer.withAlpha(179);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isQuestionArabic = _currentQuestion.questionText.contains(
      RegExp(r'[\u0600-\u06FF]'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1} of ${widget.quiz.questions.length}',
        ),
      ),
      body: SingleChildScrollView(
        // --- NEW: Attach the controller ---
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            child: Column(
              key: ValueKey<int>(_currentIndex),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withAlpha(26),
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
                      onPressed: _isAnswered
                          ? null
                          : () => _handleAnswer(option),
                      style: ElevatedButton.styleFrom(
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
      ),
    );
  }
}
