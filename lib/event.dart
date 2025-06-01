enum EventStatus { done, upcoming, postponed }


class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String? imagePath;
  final List<String> people;
  final bool isRecommendation;
  final bool isRecurring;
  final String? recurrenceType; // "monthly", "yearly"
  final EventStatus status; // Ubah dari bool ke enum

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.imagePath,
    required this.people,
    this.isRecommendation = false,
    this.isRecurring = false,
    this.recurrenceType,
    this.status = EventStatus.upcoming,  // Default status
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? imagePath,
    List<String>? people,
    bool? isRecommendation,
    bool? isRecurring,
    String? recurrenceType,
    EventStatus? status,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
      people: people ?? this.people,
      isRecommendation: isRecommendation ?? this.isRecommendation,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      status: status ?? this.status,
    );
  }
}
