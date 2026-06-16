class Diary {
  final String? id; 
  final DateTime date;
  final String content;

  Diary({this.id, required this.date, required this.content});

  Map<String, dynamic> toJson() {
    return {'id': id, 'date': date.toIso8601String(), 'content': content};
  }

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String,
    );
  }
}
