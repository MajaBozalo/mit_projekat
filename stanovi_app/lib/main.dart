import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ovo je onaj fajl koji smo pravili!

void main() async {
  // Ovo osigurava da je sve spremno pre nego što se aplikacija upali
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ovo povezuje tvoju aplikaciju sa Firebase-om
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Izdavanje Stanova',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Firebase je povezan! 🎉',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}