import 'dart:convert'; // For jsonDecode
import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For number input formatter
import 'package:animations/animations.dart'; // For page transitions
import 'package:mobile_app/screens/quiz_screen.dart'; // The Quiz screen
import 'package:mobile_app/screens/select_surah_screen.dart'; // Screen to select Surah
import 'package:mobile_app/services/api_service.dart'; // Service to fetch data

// Main widget for the Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables
  bool _isLoading = false; // Tracks loading state for blur effect
  final ApiService _apiService = ApiService(); // Service to fetch quizzes
  int _currentSurah = 2; // Default Surah (Al-Baqarah)
  Map<String, String> _surahNames = {}; // Holds loaded Surah names (String key)

  @override
  void initState() {
    super.initState();
    // Load the Surah names from the JSON asset when the screen is first built
    _loadSurahNames();
  }

  // Asynchronously loads Surah names from the bundled JSON file
  Future<void> _loadSurahNames() async {
    try {
      // Load the JSON file content as a string
      final String jsonString = await rootBundle.loadString(
        'assets/data/surah_names.json',
      );
      // Decode the JSON string into a Map
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      // Update the state with the loaded names, ensuring keys/values are strings
      if (mounted) {
        // Check if the widget is still active
        setState(() {
          _surahNames = jsonMap.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        });
      }
    } catch (e) {
      debugPrint("Error loading Surah names: $e");
      // Handle potential errors (e.g., file not found, invalid JSON)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load Surah names.')),
        );
      }
    }
  }

  // Fetches the quiz data and navigates to the QuizScreen
  Future<void> _startQuiz(QuizType quizType) async {
    if (!mounted) return; // Prevent state updates if widget is disposed
    setState(() {
      _isLoading = true;
    }); // Show loading indicator (blur)

    try {
      // Call the API service to get quiz data for the current Surah
      final quiz = await _apiService.fetchQuiz(quizType, _currentSurah);

      if (!mounted) return; // Check again after await

      // Navigate using PageRouteBuilder for custom transition
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuizScreen(quiz: quiz), // Pass quiz data to the next screen
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Use Material Design's Shared Axis transition for horizontal slide
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          transitionDuration: const Duration(
            milliseconds: 400,
          ), // Animation speed
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Show an error message if fetching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Display a cleaner error message
          content: Text(
            'Error: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.error, // Use theme error color
        ),
      );
    } finally {
      // Ensure loading indicator is hidden, even if errors occur
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Navigates to the SelectSurahScreen to allow the user to change Surah
  Future<void> _changeSurah() async {
    // Navigate and wait for a result (the selected Surah number)
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectSurahScreen(
          surahNames: _surahNames, // Pass the loaded names
          currentSurah: _currentSurah, // Pass the currently selected Surah
        ),
      ),
    );

    // If a valid new number was returned and it's different, update the state
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
    // Define a reusable button style for consistency
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18),
    );

    // Get the display name for the current Surah from the loaded map
    final String currentSurahName =
        _surahNames[_currentSurah.toString()] ??
        'Surah $_currentSurah'; // Fallback if name not found

    return Scaffold(
      body: Stack(
        // Use Stack to layer the blur effect over the content
        children: [
          // Main content area
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the current Surah and the 'Change' button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        // Allow text to wrap if name is long
                        child: Text(
                          'Studying: $currentSurahName',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Prevent long names from breaking layout
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        // Disable button during loading
                        onPressed: _isLoading ? null : _changeSurah,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Spacing
                  // Scrollable column for the quiz buttons
                  Flexible(
                    // Allows the button column to take remaining space
                    child: SingleChildScrollView(
                      // Enables scrolling if buttons overflow
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- CORRECTED BUTTON NAMES ---
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
                          // --- END CORRECTED NAMES ---
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conditional loading overlay (blur effect) shown while fetching data
          if (_isLoading)
            Positioned.fill(
              // Ensures the overlay covers the entire screen
              child: BackdropFilter(
                // Apply a blur effect to the background
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  // Add a slight dark tint over the blur
                  color: Colors.black.withAlpha(26), // ~10% opacity
                  alignment: Alignment.center,
                  // Optional: Add a subtle loading indicator on top of the blur
                  // child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
