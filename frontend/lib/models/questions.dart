class Question {
  final int id;
  final String text;
  final String type;
  final List<String> options;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      options: List<String>.from(json['options']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'type': type, 'options': options};
  }
}
