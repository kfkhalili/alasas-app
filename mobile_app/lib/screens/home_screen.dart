import 'package:flutter/material.dart';
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
      _isLoading = true;
    });

    try {
      final quiz = await _apiService.fetchQuiz(quizType);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Use a consistent style for all buttons ---
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Al-Asas')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () => _startQuiz(QuizType.ayahToMeaning),
                        style: buttonStyle, // Use shared style
                        child: const Text('Ayah to Meaning Quiz'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _startQuiz(QuizType.ayahToNumber),
                        style: buttonStyle, // Use shared style
                        child: const Text('Ayah to Number Quiz'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _startQuiz(QuizType.nextAyah),
                        style: buttonStyle, // Use shared style
                        child: const Text('Next Ayah Quiz'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _startQuiz(QuizType.conceptToAyah),
                        style: buttonStyle, // Use shared style
                        child: const Text('Concept Quiz'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _startQuiz(QuizType.diacriticQuiz),
                        style: buttonStyle, // Use shared style
                        child: const Text('Diacritic Quiz'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
