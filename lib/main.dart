import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'event_provider.dart';
import 'home.dart';
import 'login.dart';
import 'firebase_options.dart';

// -------- Notifikasi lokal ----------
final FlutterLocalNotificationsPlugin notifs = FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifs() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: android, iOS: ios);
  await notifs.initialize(initSettings);
}

// -------- Google Sign‑In -------------
final GoogleSignIn gSignIn = GoogleSignIn(
  clientId: '635022092732-dklpusktie6iq609n1u62hbh6pib6v7p.apps.googleusercontent.com',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/calendar',
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notifikasi
  await _initLocalNotifs();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: MaterialApp(
        title: 'Scheduling',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthGate(),
      ),
    );
  }
}

/// Menentukan halaman mana yang tampil tergantung status login Firebase
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasData) {
          return const HomePage(); // sudah login
        }
        return const OnboardingPage(); // belum login
      },
    );
  }
}
