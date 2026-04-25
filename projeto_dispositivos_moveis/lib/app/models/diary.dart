class Diary {
  final String? id;
  final String text;
  final DateTime date;

  Diary({
    this.id,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'date': date.toIso8601String(),
    };
  }
}