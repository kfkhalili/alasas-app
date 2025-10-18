import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:mobile_app/screens/quiz_screen.dart';
import 'package:mobile_app/screens/select_surah_screen.dart';
import 'package:mobile_app/services/api_service.dart';

@immutable
class HomeScreenState {
  final bool isLoading;
  final int currentSurah;
  final Map<String, String> surahNames;

  const HomeScreenState({
    this.isLoading = false,
    this.currentSurah = 2, // Default to Surah Al-Baqarah
    this.surahNames = const {},
  });

  HomeScreenState copyWith({
    bool? isLoading,
    int? currentSurah,
    Map<String, String>? surahNames,
  }) {
    return HomeScreenState(
      isLoading: isLoading ?? this.isLoading,
      currentSurah: currentSurah ?? this.currentSurah,
      surahNames: surahNames ?? this.surahNames,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late final ValueNotifier<HomeScreenState> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(const HomeScreenState());
    _loadSurahNames();
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSurahNames() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/surah_names.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      if (!mounted) return;
      _stateNotifier.value = _stateNotifier.value.copyWith(
        surahNames: jsonMap.map((key, value) => MapEntry(key, value.toString())),
      );
    } catch (e) {
      debugPrint("Error loading Surah names: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load Surah names.')),
      );
    }
  }

  Future<void> _startQuiz(QuizType quizType) async {
    if (!mounted) return;
    _stateNotifier.value = _stateNotifier.value.copyWith(isLoading: true);

    try {
      final quiz = await _apiService.fetchQuiz(
          quizType, _stateNotifier.value.currentSurah);
      if (!mounted) return;
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
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        _stateNotifier.value = _stateNotifier.value.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _changeSurah() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectSurahScreen(
          surahNames: _stateNotifier.value.surahNames,
          currentSurah: _stateNotifier.value.currentSurah,
        ),
      ),
    );

    if (result != null && result != _stateNotifier.value.currentSurah) {
      _stateNotifier.value = _stateNotifier.value.copyWith(currentSurah: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeScreenState>(
      valueListenable: _stateNotifier,
      builder: (context, state, child) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SurahDisplay(
                        surahNames: state.surahNames,
                        currentSurah: state.currentSurah,
                        isLoading: state.isLoading,
                        onChangeSurah: _changeSurah,
                      ),
                      const SizedBox(height: 30),
                      Flexible(
                        child: _QuizButtons(
                          isLoading: state.isLoading,
                          onStartQuiz: _startQuiz,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isLoading) const _LoadingIndicator(),
            ],
          ),
        );
      },
    );
  }
}

class _SurahDisplay extends StatelessWidget {
  final Map<String, String> surahNames;
  final int currentSurah;
  final bool isLoading;
  final VoidCallback onChangeSurah;

  const _SurahDisplay({
    required this.surahNames,
    required this.currentSurah,
    required this.isLoading,
    required this.onChangeSurah,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahName =
        surahNames[currentSurah.toString()] ?? 'Surah $currentSurah';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Studying: $surahName',
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: isLoading ? null : onChangeSurah,
          child: const Text('Change'),
        ),
      ],
    );
  }
}

class _QuizButtons extends StatelessWidget {
  final bool isLoading;
  final void Function(QuizType) onStartQuiz;

  const _QuizButtons({required this.isLoading, required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isLoading ? null : () => onStartQuiz(QuizType.ayahToMeaning),
            style: buttonStyle,
            child: const Text('Meaning Match'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : () => onStartQuiz(QuizType.ayahToNumber),
            style: buttonStyle,
            child: const Text('Verse Location'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : () => onStartQuiz(QuizType.nextAyah),
            style: buttonStyle,
            child: const Text('Sequence Recall'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : () => onStartQuiz(QuizType.conceptToAyah),
            style: buttonStyle,
            child: const Text('Concept Check'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : () => onStartQuiz(QuizType.diacriticQuiz),
            style: buttonStyle,
            child: const Text('Verse Endings'),
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.1),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
