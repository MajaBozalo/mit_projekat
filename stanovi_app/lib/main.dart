import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Dodato za proveru prijave
import 'firebase_options.dart';
import 'gost.dart';
import 'admin_page.dart'; // Proveri da li si napravila ovaj fajl

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StanoviApp());
}

class StanoviApp extends StatelessWidget {
  const StanoviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F5D8C),
          brightness: Brightness.light,
        ),
      ),
      // Umesto direktnog odlaska na GostPage, idemo na AuthWrapper
      home: const AuthWrapper(),
    );
  }
}

// OVO JE "MOZAK" KOJI ODREĐUJE ŠTA KORISNIK VIDI
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // I ulogovan i neulogovan korisnik sada idu na istu stranicu
        // jer GostPage sama crta dugmiće na osnovu statusa
        return const GostPage(); 
      },
    );
  }
}