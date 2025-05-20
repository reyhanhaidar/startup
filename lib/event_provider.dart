import 'package:flutter/foundation.dart';
import 'event.dart';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => [..._events];

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
}
