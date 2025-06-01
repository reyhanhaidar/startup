import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_provider.dart';
import 'event.dart';

class EventAnalysisScreen extends StatelessWidget {
  const EventAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;

    int done = 0, upcoming = 0, postponed = 0;
    final now = DateTime.now();

    for (var e in events) {
      switch (e.status) {
        case EventStatus.done:
          done++;
          break;
        case EventStatus.upcoming:
          upcoming++;
          break;
        case EventStatus.postponed:
          postponed++;
          break;
      }
    }

    final total = done + upcoming + postponed;

    return Scaffold(
      appBar: AppBar(title: Text('Analisis Event')),
      body: Center(
        child: total == 0
            ? Text('Belum ada data event.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Distribusi Status Event',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: done.toDouble(),
                            title: 'Selesai\n$done',
                            radius: 60,
                            titleStyle:
                                TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          PieChartSectionData(
                            color: Colors.blue,
                            value: upcoming.toDouble(),
                            title: 'Belum\n$upcoming',
                            radius: 60,
                            titleStyle:
                                TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: postponed.toDouble(),
                            title: 'Tunda\n$postponed',
                            radius: 60,
                            titleStyle:
                                TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Total Event: $total'),
                ],
              ),
      ),
    );
  }
}
