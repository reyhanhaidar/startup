// event_provider.dart

import 'package:flutter/foundation.dart';
import 'event.dart';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => [..._events];

  int get total => _events.length;
  int get done => _events.where((e) => e.status == EventStatus.completed).length;
  int get fail => _events.where((e) => e.status == EventStatus.failed).length;

  double get doneRatio => total == 0 ? 0 : done / total;
  double get failRatio => total == 0 ? 0 : fail / total;

  int get totalPoints =>
      _events.where((e) => e.status == EventStatus.completed).fold(0, (sum, e) => sum + e.point);

  List<Event> get completedEvents => _events.where((e) => e.status == EventStatus.completed).toList();

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  // Add event without notifying listeners (for bulk operations like loading from Google Calendar)
  void addEventSilently(Event event) {
    _events.add(event);
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }

  void updateEvent(Event updatedEvent) {
    final idx = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (idx != -1) {
      _events[idx] = updatedEvent;
      notifyListeners();
    }
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  // Get events by title for pattern detection
  List<Event> getEventsByTitle(String title) {
    return _events.where((e) => e.title.toLowerCase() == title.toLowerCase()).toList();
  }

  // Check if there are consecutive weekly events
  bool hasConsecutiveWeeklyPattern(String title, {int minWeeks = 3}) {
    final sameTitleEvents = getEventsByTitle(title);
    if (sameTitleEvents.length < minWeeks) return false;

    final sortedEvents = sameTitleEvents..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    int consecutiveWeeks = 1;
    int targetWeekday = sortedEvents.first.dateTime.weekday;

    for (int i = 1; i < sortedEvents.length; i++) {
      final expectedDate = sortedEvents[i - 1].dateTime.add(Duration(days: 7));
      final actualDate = sortedEvents[i].dateTime;

      // Check if it's the same weekday and exactly 7 days apart
      if (actualDate.weekday == targetWeekday && _isSameDay(expectedDate, actualDate)) {
        consecutiveWeeks++;
        if (consecutiveWeeks >= minWeeks) return true;
      } else {
        consecutiveWeeks = 1;
        targetWeekday = actualDate.weekday;
      }
    }

    return consecutiveWeeks >= minWeeks;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
