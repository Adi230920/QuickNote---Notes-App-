class Note {
  final int? id;
  final String title;
  final String content;
  bool isLocked;
  String? pin;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.isLocked = false,
    this.pin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isLocked': isLocked ? 1 : 0,
      'pin': pin,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isLocked: map['isLocked'] == 1,
      pin: map['pin'],
    );
  }
}
