import 'package:event/event_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'date_page.dart';
import 'login.dart';
import 'main.dart';

class AnalisisPage extends StatelessWidget {
  const AnalisisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final completed = provider.completedEvents;
    final stats = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List Tanggal Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'List tanggal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 16),

            // Date List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateItem('Senin', 0, 0),
                _buildDateItem('Selasa', 0, 0),
                _buildDateItem('Rabu', 0, 0),
                _buildDateItem('Kamis', 0, 0),
                _buildDateItem('Jumat', 0, 0),
                _buildDateItem('Sabtu', 0, 0),
                _buildDateItem('Minggu', 0, 0),
              ],
            ),

            const SizedBox(height: 32),

            // Analisis Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Analisis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 16),

            // Chart Container
            GestureDetector(
              onTapUp: (d) => _showTooltip(context, stats),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: PieChartPainter(
                    doneRatio: stats.doneRatio,
                    failRatio: stats.failRatio,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Hasil Analisis Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hasil Analisis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 16),

            // Analysis Results
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisCard('Selesai', stats.doneRatio),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalysisCard('Tidak Selesai', stats.failRatio),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Hasil Poin
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Poin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 16),
            Text("Total Poin: ${provider.totalPoints}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Event Diselesaikan:"),
            ...completed.map((e) => ListTile(
                  title: Text(e.title),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(e.dateTime)),
                  trailing: Text("+${e.point} poin"),
                )),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey[600],
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TanggalPage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Tanggal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analisis',
            ),
          ],
        ),
      ),
    );
  }

  void _showTooltip(BuildContext context, EventProvider stats) {
    final done = stats.done;
    final fail = stats.fail;
    final total = stats.total;
    final pending = total - done - fail;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rincian Kegiatan'),
        content: Text(
          'Selesai  : $done\n'
          'Tidak selesai : $fail\n'
          'Pending : $pending',
        ),
        actions: [
          TextButton(
            child: const Text('Tutup'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

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

  Widget _buildDateItem(String day, int done, int fail) {
    final color = done > 0
        ? Colors.teal
        : fail > 0
            ? Colors.redAccent
            : Colors.grey[300];
    return Column(
      children: [Container(width: 40, height: 40, color: color), SizedBox(height: 8), Text(day)],
    );
  }

  Widget _buildAnalysisCard(String title, double ratio) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${(ratio * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PieChartPainter extends CustomPainter {
  final double doneRatio; // 0‒1
  final double failRatio; // 0‒1

  PieChartPainter({
    required this.doneRatio,
    required this.failRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 5.5;

    final donePaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.fill;
    final failPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    final pendingPaint = Paint()..color = Colors.grey[600]!;

    // sudut radian
    final doneSweep = doneRatio * 2 * 3.1416;
    final failSweep = failRatio * 2 * 3.1416;
    final pendingSweep = 2 * 3.1416 - doneSweep - failSweep;

    double start = -3.1416 / 2; // mulai dari atas

    // DONE
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, doneSweep, true, donePaint);
    start += doneSweep;

    // FAIL
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, failSweep, true, failPaint);
    start += failSweep;

    // PENDING
    if (pendingSweep > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius), start, pendingSweep, true, pendingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) =>
      old.doneRatio != doneRatio || old.failRatio != failRatio;
}
