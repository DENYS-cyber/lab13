class Note {
  final int? id;
  final String text;
  final DateTime createdAt;

  Note({
    this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "text": text,
      "created_at": createdAt.toIso8601String(),
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map["id"],
      text: map["text"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }
}
