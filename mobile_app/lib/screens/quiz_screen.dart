import 'package:flutter/material.dart';
import 'package:mobile_app/models/question_model.dart';
import 'package:mobile_app/models/quiz_model.dart';
import 'package:mobile_app/screens/results_screen.dart';

// --- Functional & Immutable Approach ---

/// Represents the immutable state of the quiz at any given time.
@immutable
class QuizState {
  final int currentIndex;
  final String? selectedAnswer;
  final bool isAnswered;
  final int score;
  final List<String> userAnswers;

  const QuizState({
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isAnswered = false,
    this.score = 0,
    this.userAnswers = const [],
  });

  /// Creates a copy of the state with updated values.
  QuizState copyWith({
    int? currentIndex,
    String? selectedAnswer,
    bool? isAnswered,
    int? score,
    List<String>? userAnswers,
    bool clearSelectedAnswer = false,
  }) {
    return QuizState(
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer:
          clearSelectedAnswer ? null : selectedAnswer ?? this.selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      score: score ?? this.score,
      userAnswers: userAnswers ?? this.userAnswers,
    );
  }
}

/// A screen that presents a quiz to the user, one question at a time.
///
/// This widget manages the display of questions, handles user input, and
/// transitions between questions. Once the quiz is complete, it navigates
/// to the [ResultsScreen].
class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final ValueNotifier<QuizState> _quizStateNotifier;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _quizStateNotifier = ValueNotifier(const QuizState());
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _quizStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Processes the user's selected answer.
  void _handleAnswer(String answer) {
    final currentState = _quizStateNotifier.value;
    final currentQuestion = widget.quiz.questions[currentState.currentIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    _quizStateNotifier.value = currentState.copyWith(
      selectedAnswer: answer,
      isAnswered: true,
      score: isCorrect ? currentState.score + 1 : currentState.score,
      userAnswers: [...currentState.userAnswers, answer],
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (currentState.currentIndex < widget.quiz.questions.length - 1) {
        _quizStateNotifier.value = currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          isAnswered: false,
          clearSelectedAnswer: true,
        );
        _scrollController.jumpTo(0.0);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              score: _quizStateNotifier.value.score,
              questions: widget.quiz.questions,
              userAnswers: _quizStateNotifier.value.userAnswers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QuizState>(
      valueListenable: _quizStateNotifier,
      builder: (context, quizState, child) {
        final currentQuestion = widget.quiz.questions[quizState.currentIndex];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Question ${quizState.currentIndex + 1} of ${widget.quiz.questions.length}',
            ),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: Column(
                  key: ValueKey<int>(quizState.currentIndex),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuestionDisplay(question: currentQuestion),
                    const SizedBox(height: 32),
                    ...currentQuestion.options.map(
                      (option) => _AnswerButton(
                        option: option,
                        isAnswered: quizState.isAnswered,
                        selectedAnswer: quizState.selectedAnswer,
                        correctAnswer: currentQuestion.correctAnswer,
                        onPressed: () => _handleAnswer(option),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Pure Widget Functions ---

class _QuestionDisplay extends StatelessWidget {
  final Question question;

  const _QuestionDisplay({required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = question.questionText.contains(RegExp(r'[\u0600-\u06FF]'));

    return Container(
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
        question.questionText,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontFamily: isArabic ? 'NotoNaskhArabic' : null,
          fontSize: isArabic ? 24 : 20,
          height: 1.5,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String option;
  final bool isAnswered;
  final String? selectedAnswer;
  final String correctAnswer;
  final VoidCallback onPressed;

  const _AnswerButton({
    required this.option,
    required this.isAnswered,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = option.contains(RegExp(r'[\u0600-\u06FF]'));
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = _getButtonColor(
        colorScheme, isAnswered, option == correctAnswer, option == selectedAnswer);
    final textColor = _getTextColor(
        colorScheme, isAnswered, option == correctAnswer, option == selectedAnswer);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: isAnswered ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          option,
          textAlign: TextAlign.center,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontFamily: isArabic ? 'NotoNaskhArabic' : null,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// --- Pure Helper Functions ---

Color _getButtonColor(ColorScheme colorScheme, bool isAnswered,
    bool isCorrect, bool isSelected) {
  if (!isAnswered) return colorScheme.secondaryContainer;
  if (isCorrect) return Colors.green;
  if (isSelected) return colorScheme.error;
  return colorScheme.secondaryContainer.withAlpha(128);
}

Color _getTextColor(ColorScheme colorScheme, bool isAnswered,
    bool isCorrect, bool isSelected) {
  if (!isAnswered) return colorScheme.onSecondaryContainer;
  if (isCorrect) return Colors.white;
  if (isSelected) return colorScheme.onError;
  return colorScheme.onSecondaryContainer.withAlpha(179);
}
