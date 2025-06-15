import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analisis_page.dart';
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
          actions: [
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AnalisisPage()));
              },
            ),
          ],
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
                  if (event.isRecurring) {
                    cardColor = Colors.deepOrange[100];
                  } else if (count == 1) {
                    cardColor = Colors.yellow[100];
                  } else if (count >= 3 && count < 7) {
                    cardColor = Colors.orange[200];
                  } else if (count >= 7) {
                    cardColor = Colors.red[200];
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: cardColor,
                    child: ListTile(
                      leading: event.imagePath != null
                          ? Image.file(File(event.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.event),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(event.title)),
                          if (event.isRecurring)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Recurring',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            )
                          else if (count >= 3)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Frequent',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'complete') {
                            provider.updateEvent(event.copyWith(status: EventStatus.completed, point: 10));
                          } else if (value == 'fail') {
                            provider.updateEvent(event.copyWith(status: EventStatus.failed));
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'complete', child: Text('Tandai Selesai')),
                          PopupMenuItem(value: 'fail', child: Text('Tandai Gagal')),
                        ],
                      ),
                    ),
                  );
                },
              ));
  }
}
