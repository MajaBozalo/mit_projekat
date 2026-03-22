import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // Funkcija za odjavu
  void odjaviSe() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          "Moj Admin Panel", 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Dugme za Logout u desnom uglu
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: odjaviSe,
            tooltip: "Odjavi se",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              "Dobrodošli, ${FirebaseAuth.instance.currentUser?.email}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Ovde ćete moći da dodajete i menjate svoje stanove.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      // Dugme za dodavanje novog sadržaja
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ovde ćemo kasnije otvoriti formu za novi stan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Forma za dodavanje stana stiže uskoro!")),
          );
        },
        backgroundColor: const Color(0xFF2F5D8C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}