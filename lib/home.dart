import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'event_provider.dart';
import 'event.dart';
import 'date_page.dart';
import 'analisis_page.dart';
import 'login.dart';
import 'main.dart';
import 'task_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final events = provider.events;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Kegiatan'),
            const SizedBox(height: 16),
            events.isEmpty
                ? _emptyState('Belum ada event', Icons.task_alt)
                : SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _activityCard(events[i]),
                    ),
                  ),
            const SizedBox(height: 32),
            _sectionHeader('List tanggal'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'].map(_dateItem).toList(),
            ),
            const SizedBox(height: 32),
            _sectionHeader('Analisis'),
            const SizedBox(height: 16),
            _analysisCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // TODO: sambungkan ke TaskDetailPage / dialog tambah Event
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailPage(
                isEdit: false,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _bottomNav(context, 0),
    );
  }

  // ---------- UI helpers ----------
  PreferredSizeWidget _buildAppBar(BuildContext ctx) {
    final user = FirebaseAuth.instance.currentUser;

    return AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      leading: Builder(
        builder: (c) => IconButton(
          onPressed: () => Scaffold.of(c).openDrawer(),
          icon: user != null && user.photoURL != null
              ? CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(user.photoURL!),
                )
              : const Icon(Icons.account_circle, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext ctx) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _drawerHeader(),
            _drawerItem(ctx, Icons.home, 'Home', const HomePage()),
            _drawerItem(ctx, Icons.calendar_today, 'Tanggal', const TanggalPage()),
            _drawerItem(ctx, Icons.analytics, 'Analisis', const AnalisisPage()),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan'),
                onTap: () => Navigator.pop(ctx)),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () async {
                // ── dialog konfirmasi ────────────────────────────────────
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Yakin mau keluar dari akun?'),
                    actions: [
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () => Navigator.pop(dCtx, false),
                      ),
                      ElevatedButton(
                        child: const Text('Keluar'),
                        onPressed: () => Navigator.pop(dCtx, true),
                      ),
                    ],
                  ),
                );

                // kalau user pilih "Keluar"
                if (confirm == true) {
                  Navigator.pop(ctx); // tutup drawer

                  await FirebaseAuth.instance.signOut();
                  await gSignIn.signOut();

                  if (ctx.mounted) {
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OnboardingPage()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      );

  Widget _drawerHeader() {
    final user = FirebaseAuth.instance.currentUser;

    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.teal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto profil
          user != null && user.photoURL != null
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.photoURL!),
                )
              : const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.teal),
                ),

          const SizedBox(height: 16),

          // Nama
          Text(
            user?.displayName ?? 'Guest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext ctx, IconData icon, String label, Widget page) => ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: () {
          Navigator.pop(ctx);
          if (page.runtimeType != runtimeType) {
            Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => page));
          }
        },
      );

  Widget _sectionHeader(String title) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
          Icon(Icons.arrow_forward, color: Colors.grey[600]),
        ],
      );

  Widget _emptyState(String msg, IconData ic) => Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ic, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text(msg,
                  style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );

  Widget _activityCard(Event e) {
    final dateStr = DateFormat('dd MMM').format(e.dateTime);
    final timeStr = DateFormat('HH:mm').format(e.dateTime);
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TaskDetailPage(
                      isEdit: true,
                      /* initialEvent:e */
                      initialEvent: e.copyWith(googleEventId: e.googleEventId, isFromGoogle: e.isFromGoogle),
                    )));
      },
      child: Container(
        width: 140,
        decoration: _cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (e.status == EventStatus.completed)
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('+${e.point}', style: const TextStyle(fontSize: 10, color: Colors.green)),
                  ],
                )
              else
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(e.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                ]),
              const SizedBox(height: 8),
              Text(e.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ]),
              Row(children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analysisCard() => Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Analisis Placeholder')),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.2), blurRadius: 4)],
      );

  Widget _dateItem(String day) => Column(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 8),
          Text(day, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      );

  Widget _bottomNav(BuildContext ctx, int idx) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: idx,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey[600],
          onTap: (i) {
            if (i == 1) {
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TanggalPage()));
            } else if (i == 2) {
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AnalisisPage()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Tanggal'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analisis'),
          ],
        ),
      );
}
