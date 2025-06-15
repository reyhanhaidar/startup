import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'calendar_client.dart';
import 'event.dart';
import 'event_provider.dart';
import 'main.dart';

class TaskDetailPage extends StatefulWidget {
  /// `isEdit == true` → update event yang sudah ada.
  /// Kalau edit, wajib kirim `initialEvent`.
  final bool isEdit;
  final Event? initialEvent;

  const TaskDetailPage({
    super.key,
    required this.isEdit,
    this.initialEvent,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _uuid = const Uuid();
  final CalendarClient calendarClient = CalendarClient(); // mis. global

  // ── Controllers ────────────────────────────────────────
  late final TextEditingController _titleC;
  late final TextEditingController _summaryC;
  late final TextEditingController _detailsC;
  late final TextEditingController _dateC;
  late final TextEditingController _startC;
  late final TextEditingController _endC;

  // Nilai aktual
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  @override
  void initState() {
    super.initState();

    final e = widget.initialEvent;

    _titleC = TextEditingController(text: e?.title ?? '');
    _summaryC = TextEditingController(text: e?.description.split('\n').firstOrNull ?? '');
    _detailsC = TextEditingController(text: e?.description ?? '');

    _dateC = TextEditingController(text: e != null ? DateFormat('dd/MM/yyyy').format(e.dateTime) : '');
    _startC = TextEditingController(text: e != null ? DateFormat('HH:mm').format(e.dateTime) : '');
    _endC = TextEditingController(
        text: e != null && e.endDateTime != null ? DateFormat('HH:mm').format(e.endDateTime!) : '');

    if (e != null) {
      _selectedDate = e.dateTime;
      _startTime = TimeOfDay.fromDateTime(e.dateTime);
      if (e.endDateTime != null) {
        _endTime = TimeOfDay.fromDateTime(e.endDateTime!);
      }
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _summaryC.dispose();
    _detailsC.dispose();
    _dateC.dispose();
    _startC.dispose();
    _endC.dispose();
    super.dispose();
  }

  // ── UI ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          if (widget.isEdit)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Tandai Selesai',
              onPressed: _markCompleted,
            ),
          if (widget.isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus',
              onPressed: _deleteEvent,
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _taskHeaderCard(),
            const SizedBox(height: 16),
            _pickDateField(context),
            const SizedBox(height: 16),
            _pickTimeField(context),
            const SizedBox(height: 32),
            _submitButton(context),
          ],
        ),
      ),
    );
  }

  // ── KOMPONEN ────────────────────────────────────────────
  Widget _taskHeaderCard() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal, width: 2),
        ),
        child: Column(
          children: [
            // judul + summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _dummyIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleC,
                          decoration: const InputDecoration(
                            hintText: 'Judul Kegiatan',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        TextField(
                          controller: _summaryC,
                          decoration: const InputDecoration(
                            hintText: 'Ringkasan singkat',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // detail panjang
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detailsC,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        hintText: 'Tuliskan detail kegiatan...', border: InputBorder.none),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _pickDateField(BuildContext ctx) => _boxedField(
        controller: _dateC,
        hint: 'Tanggal',
        icon: Icons.calendar_today,
        onTap: () async {
          final picked = await showDatePicker(
            context: ctx,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
              _dateC.text = DateFormat('dd/MM/yyyy').format(picked);
            });
          }
        },
      );

  Widget _pickTimeField(BuildContext ctx) => Row(
        children: [
          Expanded(
            child: _boxedField(
              controller: _startC,
              hint: 'Jam Mulai',
              icon: Icons.access_time,
              onTap: () async {
                final t = await showTimePicker(context: ctx, initialTime: _startTime ?? TimeOfDay.now());
                if (t != null) {
                  setState(() {
                    _startTime = t;
                    _startC.text = t.format(ctx);
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _boxedField(
              controller: _endC,
              hint: 'Jam Selesai',
              icon: Icons.access_time,
              onTap: () async {
                final t = await showTimePicker(context: ctx, initialTime: _endTime ?? TimeOfDay.now());
                if (t != null) {
                  setState(() {
                    _endTime = t;
                    _endC.text = t.format(ctx);
                  });
                }
              },
            ),
          ),
        ],
      );

  // Kotak putih seragam
  Widget _boxedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: onTap,
              ),
            ),
            Icon(icon, color: Colors.grey),
          ],
        ),
      );

  Widget _submitButton(BuildContext ctx) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _saveEvent,
          child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );

  // ── ACTIONS ─────────────────────────────────────────────
  Future<void> _saveEvent() async {
    if (_selectedDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal & waktu mulai belum lengkap')),
      );
      return;
    }

    // Gabungkan tanggal & jam
    final startDT = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    DateTime? endDT;
    if (_endTime != null) {
      endDT = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    final provider = context.read<EventProvider>();

    // ------- Tambah / update di state lokal -------
    late Event currentEvent;
    if (widget.isEdit && widget.initialEvent != null) {
      currentEvent = widget.initialEvent!.copyWith(
        title: _titleC.text.trim(),
        description: _detailsC.text.trim(),
        dateTime: startDT,
        endDateTime: endDT,
      );
      provider.updateEvent(currentEvent);
    } else {
      currentEvent = Event(
        id: _uuid.v4(),
        title: _titleC.text.trim(),
        description: _detailsC.text.trim(),
        dateTime: startDT,
        endDateTime: endDT,
        people: const [],
      );
      provider.addEvent(currentEvent);
    }

    // ------- Sinkron ke Google Calendar -------
    try {
      if (CalendarClient.calendar == null) {
        final gClient = await gSignIn.authenticatedClient();
        if (gClient != null) {
          CalendarClient.calendar = google_calendar.CalendarApi(gClient);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harus login Google dulu')),
          );
          return;
        }
      }

      final endTime = endDT ?? startDT.add(const Duration(hours: 1));

      final result = await calendarClient.insert(
        title: currentEvent.title,
        description: currentEvent.description,
        location: '',
        attendeeEmailList: [],
        shouldNotifyAttendees: false,
        startTime: startDT,
        endTime: endTime,
      );

      final googleId = result?['id'];

      if (widget.isEdit) {
        provider.updateEvent(
          currentEvent.copyWith(googleEventId: googleId),
        );
      } else {
        provider.updateEvent(
          // ganti addEvent → updateEvent utk simpan googleId
          currentEvent.copyWith(googleEventId: googleId),
        );
      }

      print('Google Calendar insert result: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event tersimpan di Google Calendar'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkron: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    Navigator.pop(context);
  }

  Future<void> _markCompleted() async {
    final provider = context.read<EventProvider>();

    final completed = widget.initialEvent!.copyWith(
      status: EventStatus.completed,
      point: 10, // poin per event, bebas atur
    );

    provider.updateEvent(completed);

    // opsional: sinkron ke Google Calendar → tambahkan warna “green” atau update description
    try {
      await calendarClient.insert(
        title: completed.title,
        description: '${completed.description}\n\n(Status: Selesai)',
        location: '',
        attendeeEmailList: [],
        shouldNotifyAttendees: false,
        startTime: completed.dateTime,
        endTime: completed.endDateTime ?? completed.dateTime.add(const Duration(hours: 1)),
      );
    } catch (_) {}

    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteEvent() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Event?'),
        content: const Text('Aksi ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (ok == true) {
      final provider = context.read<EventProvider>();
      final googleId = widget.initialEvent?.googleEventId;

      // 1. Hapus di Google Calendar jika punya ID
      if (googleId != null && googleId.isNotEmpty) {
        await calendarClient.delete(googleId);
      }

      // 2. Hapus di state lokal
      provider.deleteEvent(widget.initialEvent!.id);

      if (mounted) Navigator.pop(context);
    }
  }

  // ── DUMMY ICON (segitiga dsb) ──────────────────────────
  Widget _dummyIcon() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Icon(Icons.event, color: Colors.grey)),
      );
}
