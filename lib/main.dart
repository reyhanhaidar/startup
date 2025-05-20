import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'event.dart';
import 'event_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'event_listscreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(
    ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: SchedulingApp(),
    ),
  );
}

class SchedulingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scheduling App',
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
  List<String> getSuggestedTitles(List<Event> events) {
    final Map<String, int> frequencyMap = {};
    for (var event in events) {
      frequencyMap[event.title] = (frequencyMap[event.title] ?? 0) + 1;
    }
    final sortedTitles = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedTitles.map((e) => e.key).toList();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _addEventDialog(BuildContext context) {
    final uuid = Uuid();
    final titleController = TextEditingController();
    final titleFocusNode = FocusNode();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    File? selectedImage;
    final List<String> people = [];
    final personController = TextEditingController();
    final picker = ImagePicker();
    final allEvents = Provider.of<EventProvider>(context, listen: false).events;
    final suggestedTitles = widget.getSuggestedTitles(allEvents);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          Future<void> _pickImage() async {
            final pickedFile =
                await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              final dir = await getApplicationDocumentsDirectory();
              final savedImage = await File(pickedFile.path)
                  .copy('${dir.path}/${p.basename(pickedFile.path)}');
              setModalState(() {
                selectedImage = savedImage;
              });
            }
          }

          return AlertDialog(
            title: Text('Add Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RawAutocomplete<String>(
                    textEditingController: titleController,
                    focusNode: titleFocusNode,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return suggestedTitles.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      titleController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(labelText: 'Title'),
                      );
                    },
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ListView.builder(
                              padding: EdgeInsets.all(8.0),
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return GestureDetector(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Wrap(
                    spacing: 6,
                    children: people
                        .map((p) => Chip(
                              label: Text(p),
                              onDeleted: () {
                                setModalState(() {
                                  people.remove(p);
                                });
                              },
                            ))
                        .toList(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setModalState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                        'Pick Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setModalState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text('Pick Time: ${selectedTime.format(context)}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Image.file(selectedImage!, height: 100),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EventListScreen()),
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final fullDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  final event = Event(
                    id: uuid.v4(),
                    title: titleController.text,
                    description: descriptionController.text,
                    dateTime: fullDateTime,
                    imagePath: selectedImage?.path,
                    people: List.from(people),
                  );

                  Provider.of<EventProvider>(context, listen: false)
                      .addEvent(event);
                  _scheduleNotification(event);
                  titleController.dispose();
                  titleFocusNode.dispose();
                  descriptionController.dispose();
                  titleController.dispose();
                  titleFocusNode.dispose();
                  descriptionController.dispose();
                  Navigator.of(ctx).pop();
                },
                child: Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  void _scheduleNotification(Event event) async {
    // Initialize timezone if not already done
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    final androidDetails = AndroidNotificationDetails(
      'event_channel_id',
      'Event Notifications',
      channelDescription: 'Notification for scheduled events',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      event.hashCode,
      'Scheduled Event: ${event.title}',
      'Scheduled for ${DateFormat('yyyy-MM-dd – kk:mm').format(event.dateTime)}',
      tz.TZDateTime.from(event.dateTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvents = provider.events
        .where(
            (event) => isSameDay(event.dateTime, _selectedDay ?? _focusedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Calendar Scheduler')),
      body: Column(
        children: [
          TableCalendar<Event>(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) => provider.events
                .where((e) => isSameDay(e.dateTime, day))
                .toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: selectedEvents.length,
              itemBuilder: (ctx, i) {
                final event = selectedEvents[i];
                return ListTile(
                  leading: event.imagePath != null
                      ? Image.file(File(event.imagePath!),
                          width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  title: Text(event.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.dateTime.toString()),
                      if (event.people.isNotEmpty)
                        Text("People: ${event.people.join(', ')}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      provider.deleteEvent(event.id);
                      flutterLocalNotificationsPlugin.cancel(event.hashCode);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addEventDialog(context),
      ),
    );
  }
}
