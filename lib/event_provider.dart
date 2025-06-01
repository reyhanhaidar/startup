import 'package:flutter/foundation.dart';
import 'event.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];
   int _points = 0;

  UnmodifiableListView<Event> get events => UnmodifiableListView(
      _events..sort((a, b) => a.dateTime.compareTo(b.dateTime)));
  int get points => _points;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }

  void updateEvent(Event updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  void updateEventStatus(String id, EventStatus newStatus) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
       final prevStatus = _events[index].status;
      _events[index] = _events[index].copyWith(status: newStatus);

    if (prevStatus != 'Selesai' && newStatus == 'Selesai') {
        _points += 10; // Tambah poin
      }
      notifyListeners();
    }
    
  }

  // -----------------------------
  // 1. Rekomendasi Otomatis Mingguan
  // -----------------------------
  void generateWeeklyRecommendations() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(Duration(days: now.weekday));
    final lastWeekEnd = lastWeekStart.add(Duration(days: 6));

    final grouped = <String, List<Event>>{};

    for (var event in _events) {
      if (event.dateTime.isAfter(lastWeekStart) &&
          event.dateTime.isBefore(lastWeekEnd)) {
        grouped.putIfAbsent(event.title, () => []).add(event);
      }
    }

    grouped.forEach((title, events) {
      if (events.length >= 3) {
        final nextWeekDate = now.add(Duration(days: 7));
        final alreadyExists = _events.any((e) =>
            e.title == title &&
            e.isRecommendation &&
            isSameWeek(e.dateTime, nextWeekDate));
        if (!alreadyExists) {
          addEvent(
            Event(
              id: Uuid().v4(),
              title: title,
              description: 'Recommended from frequent usage',
              dateTime: nextWeekDate,
              isRecommendation: true,
              people: [],
            ),
          );
        }
      }
    });
  }

  bool isSameWeek(DateTime a, DateTime b) {
    final aStart = a.subtract(Duration(days: a.weekday));
    final bStart = b.subtract(Duration(days: b.weekday));
    return aStart.year == bStart.year &&
        aStart.month == bStart.month &&
        aStart.day == bStart.day;
  }

  // -----------------------------
  // 2. Event Penting Berulang
  // -----------------------------
  void generateRecurringEvents() {
    final now = DateTime.now();

    for (var event in List<Event>.from(_events)) {
      if (!event.isRecurring || event.recurrenceType == null) continue;

      DateTime newDate;
      if (event.recurrenceType == 'monthly') {
        newDate = DateTime(now.year, now.month, event.dateTime.day);
      } else if (event.recurrenceType == 'yearly') {
        newDate = DateTime(now.year, event.dateTime.month, event.dateTime.day);
      } else {
        continue;
      }

      final alreadyExists = _events
          .any((e) => e.title == event.title && isSameDay(e.dateTime, newDate));
      if (!alreadyExists) {
        addEvent(event.copyWith(
          id: Uuid().v4(),
          dateTime: newDate,
          isRecurring: false, // prevent recursive generation
        ));
      }
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
