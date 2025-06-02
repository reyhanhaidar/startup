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

  void generateWeeklyRecommendations() {
    final now = DateTime.now();
    final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
    final nextMonth = DateTime(now.year, now.month + 1);
    final Map<String, Map<int, int>> dayCountThisMonth = {};
    final Map<String, Map<int, int>> dayCountLastMonth = {};
    final Map<String, List<DateTime>> eventDays = {};

    // Index semua event
    for (var event in _events) {
      final date = event.dateTime;
      final weekday = date.weekday;
      final title = event.title;

      // Hari ini dan bulan lalu
      if (date.month == now.month && date.year == now.year) {
        dayCountThisMonth.putIfAbsent(title, () => {});
        dayCountThisMonth[title]![weekday] =
            (dayCountThisMonth[title]![weekday] ?? 0) + 1;
      }

      if (date.month == now.month - 1 && date.year == now.year) {
        dayCountLastMonth.putIfAbsent(title, () => {});
        dayCountLastMonth[title]![weekday] =
            (dayCountLastMonth[title]![weekday] ?? 0) + 1;
      }

      // Simpan semua tanggal untuk week-based check
      eventDays.putIfAbsent(title, () => []).add(date);
    }

    final alreadyRecommended = <String, Set<DateTime>>{};

    void recommend(String title, DateTime targetDate, String reason) {
      alreadyRecommended.putIfAbsent(title, () => {});
      if (alreadyRecommended[title]!.any(
          (d) => isSameWeek(d, targetDate) && d.weekday == targetDate.weekday))
        return;

      addEvent(Event(
        id: Uuid().v4(),
        title: title,
        description: reason,
        dateTime: targetDate,
        isRecommendation: true,
        people: [],
      ));

      alreadyRecommended[title]!.add(targetDate);
    }

    // 1. ≥3x minggu lalu → rekomendasi minggu depan di hari sama
    final lastWeekStart = now.subtract(Duration(days: now.weekday));
    final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
    for (var entry in eventDays.entries) {
      final title = entry.key;
      final dates = entry.value
          .where((d) => d.isAfter(lastWeekStart) && d.isBefore(lastWeekEnd))
          .toList();
      final weekdayCount = <int, int>{};
      for (var d in dates) {
        weekdayCount[d.weekday] = (weekdayCount[d.weekday] ?? 0) + 1;
      }
      for (var day in weekdayCount.entries) {
        if (day.value >= 3) {
          final targetDate = nextMonday.add(Duration(days: day.key - 1));
          recommend(title, targetDate,
              'Frequent activity last week on ${weekdayName(day.key)}');
        }
      }
    }

    // 2. ≥3x di hari tertentu bulan ini & lalu → minggu depan hari itu
    for (var title in dayCountThisMonth.keys) {
      for (var weekday = 1; weekday <= 7; weekday++) {
        final countThis = dayCountThisMonth[title]?[weekday] ?? 0;
        final countLast = dayCountLastMonth[title]?[weekday] ?? 0;
        if (countThis >= 3 && countLast >= 3) {
          final targetDate = nextMonday.add(Duration(days: weekday - 1));
          recommend(title, targetDate,
              'Consistent on ${weekdayName(weekday)} for 2 months');
        }
      }
    }

    // 3. ≥3x dalam 3 minggu → rekomendasi minggu depan di hari sama
    final threeWeeksAgo = now.subtract(const Duration(days: 21));
    for (var entry in eventDays.entries) {
      final title = entry.key;
      final dates = entry.value.where((d) => d.isAfter(threeWeeksAgo)).toList();
      final weekdayCount = <int, int>{};
      for (var d in dates) {
        weekdayCount[d.weekday] = (weekdayCount[d.weekday] ?? 0) + 1;
      }
      for (var wc in weekdayCount.entries) {
        if (wc.value >= 3) {
          final targetDate = nextMonday.add(Duration(days: wc.key - 1));
          recommend(title, targetDate,
              'Frequent on ${weekdayName(wc.key)} in last 3 weeks');
        }
      }
    }

    // 4 & 5. W1&W3 dan W2&W4 → rekomendasi bulan depan minggu yg sama dan hari sama
    final Map<String, Map<int, Map<int, int>>> weekDayMap =
        {}; // title → weekNum → weekday → count

    for (var entry in eventDays.entries) {
      final title = entry.key;
      for (var d in entry.value) {
        final weekNum = weekOfMonth(d);
        weekDayMap.putIfAbsent(title, () => {});
        weekDayMap[title]!.putIfAbsent(weekNum, () => {});
        weekDayMap[title]![weekNum]![d.weekday] =
            (weekDayMap[title]![weekNum]![d.weekday] ?? 0) + 1;
      }
    }

    for (var title in weekDayMap.keys) {
      final w = weekDayMap[title]!;
      for (var weekday = 1; weekday <= 7; weekday++) {
        if ((w[1]?[weekday] ?? 0) >= 3 && (w[3]?[weekday] ?? 0) >= 3) {
          for (var wn in [1, 3]) {
            final date = getWeekStartDate(nextMonth, wn)
                .add(Duration(days: weekday - 1));
            recommend(
                title, date, 'Routine in W$wn on ${weekdayName(weekday)}');
          }
        }
        if ((w[2]?[weekday] ?? 0) >= 3 && (w[4]?[weekday] ?? 0) >= 3) {
          for (var wn in [2, 4]) {
            final date = getWeekStartDate(nextMonth, wn)
                .add(Duration(days: weekday - 1));
            recommend(
                title, date, 'Routine in W$wn on ${weekdayName(weekday)}');
          }
        }
      }
    }
  }

  String weekdayName(int weekday) {
    const names = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday'
    };
    return names[weekday] ?? 'Unknown';
  }

  bool isSameWeek(DateTime a, DateTime b) {
    final aStart = a.subtract(Duration(days: a.weekday));
    final bStart = b.subtract(Duration(days: b.weekday));
    return aStart.year == bStart.year &&
        aStart.month == bStart.month &&
        aStart.day == bStart.day;
  }

  DateTime getWeekStartDate(DateTime baseMonth, int weekIndex) {
    final firstDay = DateTime(baseMonth.year, baseMonth.month, 1);
    int daysOffset = ((weekIndex - 1) * 7) - (firstDay.weekday - 1);
    if (daysOffset < 0) daysOffset = 0;
    return firstDay.add(Duration(days: daysOffset));
  }

  int weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final adjustment = firstDay.weekday - 1;
    return ((date.day + adjustment - 1) ~/ 7) + 1;
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
