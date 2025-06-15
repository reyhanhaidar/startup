import 'package:googleapis/calendar/v3.dart' as google_calendar;

class CalendarClient {
  // ... (Kode Class CalendarClient tidak berubah)
  // For storing the CalendarApi object
  static google_calendar.CalendarApi? calendar;

  // For creating a new calendar event
  Future<Map<String, String>?> insert({
    required String title,
    required String description,
    required String location,
    required List<google_calendar.EventAttendee> attendeeEmailList,
    required bool shouldNotifyAttendees,
    required DateTime startTime,
    required DateTime endTime,
    String? recurrenceRule,
  }) async {
    Map<String, String>? eventData;

    try {
      String calendarId = "primary";
      google_calendar.Event event = google_calendar.Event();

      event.summary = title;
      event.description = description;
      event.attendees = attendeeEmailList;
      event.location = location;

      // Set recurrence if provided
      if (recurrenceRule != null) {
        event.recurrence = [recurrenceRule];
      }

      google_calendar.EventDateTime start = google_calendar.EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+07:00"; // Indonesia timezone
      event.start = start;

      google_calendar.EventDateTime end = google_calendar.EventDateTime();
      end.timeZone = "GMT+07:00";
      end.dateTime = endTime;
      event.end = end;

      var result = await calendar?.events
          .insert(event, calendarId, sendUpdates: shouldNotifyAttendees ? "all" : "none");

      eventData = {'id': result?.id ?? '', 'status': 'success'};
    } catch (e) {
      print('Error inserting event: $e');
      eventData = {'status': 'error', 'message': e.toString()};
    }

    return eventData;
  }

  // Fetch events from Google Calendar
  Future<List<google_calendar.Event>> getEvents({
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    try {
      if (calendar == null) return [];

      final events = await calendar!.events.list(
        'primary',
        timeMin: timeMin ?? DateTime.now().subtract(Duration(days: 30)),
        timeMax: timeMax ?? DateTime.now().add(Duration(days: 365)),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<void> delete(String googleEventId) async {
    try {
      await calendar!.events.delete('primary', googleEventId);
    } catch (e) {
      // boleh log error; tak perlu block UI
      print('Failed to delete Google event: $e');
    }
  }
}
