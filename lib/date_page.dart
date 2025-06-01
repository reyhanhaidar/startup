import 'package:event/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'analisis_page.dart';
import 'home.dart';
//import 'task_detail_page.dart';

class TanggalPage extends StatefulWidget {
  const TanggalPage({Key? key}) : super(key: key);

  @override
  State<TanggalPage> createState() => _TanggalPageState();
}

class _TanggalPageState extends State<TanggalPage> {
  List<Map<String, String>> kegiatanList = [
    {'title': 'Kegiatan\nPengguna', 'id': '1'},
    {'title': 'Kegiatan\nPengguna', 'id': '2'},
    {'title': 'Kegiatan\nPengguna', 'id': '3'},
    {'title': 'Kegiatan\nPengguna', 'id': '4'},
    {'title': 'Kegiatan\nPengguna', 'id': '5'},
    {'title': 'Kegiatan\nPengguna', 'id': '6'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {},
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
      ),
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
                _buildDateItem('Senin'),
                _buildDateItem('Selasa'),
                _buildDateItem('Rabu'),
                _buildDateItem('Kamis'),
                _buildDateItem('Jumat'),
                _buildDateItem('Sabtu'),
                _buildDateItem('Minggu'),
              ],
            ),

            const SizedBox(height: 32),

            // List Kegiatan Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'List Kegiatan',
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

            // Kegiatan Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: kegiatanList.length,
              itemBuilder: (context, index) {
                return _buildKegiatanCard(kegiatanList[index]['title']!, index);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskDetailPage(isEdit: false),
            ),
          );
          if (result != null && result is Map<String, String>) {
            setState(() {
              kegiatanList.add({
                'title': result['title'] ?? 'Kegiatan\nBaru',
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
              });
            });
          }
        },
        backgroundColor: Colors.grey[600],
        child: const Icon(Icons.add, color: Colors.white),
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
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AnalisisPage()),
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

  Widget _buildDateItem(String day) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildKegiatanCard(String title, int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              isEdit: true,
              initialTitle: title,
            ),
          ),
        );
        if (result != null && result is Map<String, String>) {
          setState(() {
            kegiatanList[index]['title'] = result['title'] ?? title;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: CustomPaint(
                  size: const Size(30, 25),
                  painter: TrianglePainter(),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
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