import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_app/screens/quiz_screen.dart';
import 'package:mobile_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _startQuiz(QuizType quizType) async {
    setState(() {
      _isLoading = true; // Start loading (blur)
    });

    try {
      final quiz = await _apiService.fetchQuiz(quizType);

      if (!mounted) return;

      // --- AWAIT the navigation ---
      // Keep loading state until the new screen is pushed
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuizScreen(quiz: quiz),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      // --- Set loading to false AFTER navigation ---
      // This ensures the blur stays until the transition is done
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18),
    );

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _startQuiz(QuizType.ayahToMeaning),
                      style: buttonStyle,
                      child: const Text('Ayah to Meaning Quiz'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _startQuiz(QuizType.ayahToNumber),
                      style: buttonStyle,
                      child: const Text('Ayah to Number Quiz'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _startQuiz(QuizType.nextAyah),
                      style: buttonStyle,
                      child: const Text('Next Ayah Quiz'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _startQuiz(QuizType.conceptToAyah),
                      style: buttonStyle,
                      child: const Text('Concept Quiz'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _startQuiz(QuizType.diacriticQuiz),
                      style: buttonStyle,
                      child: const Text('Diacritic Quiz'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- Blur Overlay ---
          if (_isLoading)
            Positioned.fill(
              // Ensure overlay covers the whole screen
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withAlpha(26),
                  alignment: Alignment.center,
                  // Optional: Add a subtle loading indicator *over* the blur
                  // child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
