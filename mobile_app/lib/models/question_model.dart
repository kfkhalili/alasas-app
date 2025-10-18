/// Represents a single quiz question.
///
/// Each question is based on a specific verse (ayah) from the Quran. It
/// includes the question text, a list of multiple-choice options, and the
/// correct answer.
class Question {
  /// The unique identifier for the verse this question is about.
  final int ayahId;

  /// The surah (chapter) number of the verse.
  final int surahNumber;

  /// The ayah (verse) number within the surah.
  final int ayahNumber;

  /// The text of the question.
  final String questionText;

  /// A list of multiple-choice options for the question.
  final List<String> options;

  /// The correct answer to the question.
  final String correctAnswer;

  /// Creates a new [Question] instance.
  ///
  /// All parameters are required.
  Question({
    required this.ayahId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  /// Creates a [Question] instance from a JSON object.
  ///
  /// This factory constructor is used to parse the JSON data received from
  /// Supabase and convert it into a [Question] object.
  ///
  /// - [json]: A map containing the question data.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      ayahId: json['ayahId'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'].map((x) => x as String)),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}
