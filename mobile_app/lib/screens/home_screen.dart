import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:mobile_app/screens/quiz_screen.dart';
import 'package:mobile_app/screens/select_surah_screen.dart';
import 'package:mobile_app/services/api_service.dart';

/// The main screen of the application, serving as the central hub for users.
///
/// From this screen, users can select a quiz type to start a new quiz,
/// or navigate to change the surah (chapter) they are currently studying.
/// It displays a list of available quiz modes and the currently selected surah.
class HomeScreen extends StatefulWidget {
  /// Creates a const [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The state for the [HomeScreen].
///
/// Manages the UI state, including loading indicators, the currently selected
/// surah, and interactions with the [ApiService] to start quizzes.
class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  int _currentSurah = 2; // Default to Surah Al-Baqarah
  Map<String, String> _surahNames = {};

  @override
  void initState() {
    super.initState();
    _loadSurahNames();
  }

  /// Loads the names of the surahs from a local JSON asset.
  ///
  /// This method reads the `surah_names.json` file from the assets, decodes it,
  /// and populates the `_surahNames` map. This map is used to display the
  /// friendly name of the currently selected surah.
  Future<void> _loadSurahNames() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/surah_names.json',
      );
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      if (mounted) {
        setState(() {
          _surahNames = jsonMap.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        });
      }
    } catch (e) {
      debugPrint("Error loading Surah names: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load Surah names.')),
        );
      }
    }
  }

  /// Starts a new quiz of the specified type.
  ///
  /// This function sets the loading state, calls the [ApiService] to fetch the
  /// quiz data, and then navigates to the [QuizScreen] upon success. It handles
  /// potential errors by displaying a [SnackBar].
  ///
  /// - [quizType]: The type of quiz to be started.
  Future<void> _startQuiz(QuizType quizType) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final quiz = await _apiService.fetchQuiz(quizType, _currentSurah);
      if (!mounted) {
        return;
      }
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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Navigates to the [SelectSurahScreen] to allow the user to change the surah.
  ///
  /// When a new surah is selected and returned from the [SelectSurahScreen],
  /// this method updates the `_currentSurah` state to reflect the change.
  Future<void> _changeSurah() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectSurahScreen(
          surahNames: _surahNames,
          currentSurah: _currentSurah,
        ),
      ),
    );

    if (result != null && result != _currentSurah) {
      if (mounted) {
        setState(() {
          _currentSurah = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18),
    );
    final String currentSurahName =
        _surahNames[_currentSurah.toString()] ?? 'Surah $_currentSurah';

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Studying: $currentSurahName',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _isLoading ? null : _changeSurah,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Flexible(
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
                            child: const Text('Meaning Match'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _startQuiz(QuizType.ayahToNumber),
                            style: buttonStyle,
                            child: const Text('Verse Location'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _startQuiz(QuizType.nextAyah),
                            style: buttonStyle,
                            child: const Text('Sequence Recall'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _startQuiz(QuizType.conceptToAyah),
                            style: buttonStyle,
                            child: const Text('Concept Check'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _startQuiz(QuizType.diacriticQuiz),
                            style: buttonStyle,
                            child: const Text('Verse Endings'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withAlpha(26),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
