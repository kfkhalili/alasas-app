class Question {
  final int ayahId;
  final int surahNumber;
  final int ayahNumber;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.ayahId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  // This is a 'factory constructor'
  // It builds a Question object from the JSON data we get from Supabase
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      ayahId: json['ayahId'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      questionText: json['questionText'] as String,
      // Converts the list of options from JSON
      options: List<String>.from(json['options'].map((x) => x as String)),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}
