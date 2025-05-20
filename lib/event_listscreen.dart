import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'event_provider.dart';
import 'event.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final events = provider.events;
    final Map<String, int> titleCount = {};

    final Set<String> seenTitles = {};

    return Scaffold(
        appBar: AppBar(
          title: Text('All Events'),
        ),
        body: events.isEmpty
            ? Center(child: Text('No events added yet.'))
            : ListView.builder(
                itemCount: events.length,
                itemBuilder: (ctx, i) {
                  final event = events[i];

                  // Hitung berapa kali judul ini muncul
                  titleCount[event.title] = (titleCount[event.title] ?? 0) + 1;
                  final count = titleCount[event.title]!;

                  Color? cardColor;
                  if (count == 1) {
                    cardColor = Colors.yellow[100];
                  } else if (count >= 3 && count < 7) {
                    cardColor = Colors.orange[200];
                  } else if (count >= 7) {
                    cardColor = Colors.red[200];
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: cardColor,
                    child: ListTile(
                      leading: event.imagePath != null
                          ? Image.file(File(event.imagePath!),
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.event),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(event.title)),
                          if (count >= 3)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Frequent',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ));
  }
}
