import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'gost.dart';
import 'admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // LOADING
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // NIJE ULOGOVAN
        if (!authSnapshot.hasData) {
          return const GostPage();
        }

        // ULOGOVAN
        final String uid = authSnapshot.data!.uid;

        // 🔍 DEBUG
        print("AUTH UID: ${FirebaseAuth.instance.currentUser?.uid}");
        print("DOC UID: $uid");

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('korisnici')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnapshot) {

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 🔍 DEBUG FIRESTORE
            print("FIRESTORE DATA: ${userSnapshot.data?.data()}");

            // AKO POSTOJI USER
            if (userSnapshot.hasData && userSnapshot.data!.exists) {

              // SIGURNO ČITANJE (bez crash-a)
              final data = userSnapshot.data!.data() as Map<String, dynamic>;

              final int userID = data['userID'] ?? 1;

              print("USER ID: $userID");

              // ADMIN
              if (userID == 0) {
                return const AdminPage();
              } 
              // GOST
              else {
                return const GostPage();
              }
            }

            // AKO NE POSTOJI DOKUMENT
            print("USER DOCUMENT DOES NOT EXIST ❌");
            return const GostPage();
          },
        );
      },
    );
  }
}