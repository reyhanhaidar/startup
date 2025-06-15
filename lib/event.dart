enum EventStatus { pending, completed, failed }

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final DateTime? endDateTime;
  final String? imagePath;
  final List<String> people;
  final bool isFromGoogle;
  final bool isRecurring;
  final EventStatus status;
  final int point;
  final String? googleEventId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.endDateTime,
    this.imagePath,
    this.people = const [],
    this.isFromGoogle = false,
    this.isRecurring = false,
    this.status = EventStatus.pending,
    this.point = 0,
    this.googleEventId,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? endDateTime,
    String? imagePath,
    List<String>? people,
    bool? isFromGoogle,
    bool? isRecurring,
    EventStatus? status,
    int? point,
    String? googleEventId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      imagePath: imagePath ?? this.imagePath,
      people: people ?? this.people,
      isFromGoogle: isFromGoogle ?? this.isFromGoogle,
      isRecurring: isRecurring ?? this.isRecurring,
      status: status ?? this.status,
      point: point ?? this.point,
      googleEventId: googleEventId ?? this.googleEventId,
    );
  }
}
