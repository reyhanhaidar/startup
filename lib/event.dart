class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? imagePath;
  final List<String> people;
  final String description; // NEW

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    this.imagePath,
    this.people = const [],
    this.description = '',
  });

  Event copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? imagePath,
    List<String>? people,
    String? description,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
      people: people ?? this.people,
      description: description ?? this.description,
    );
  }
}
