import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registracija.dart';

class PrijavaPage extends StatefulWidget {
  const PrijavaPage({super.key});

  @override
  State<PrijavaPage> createState() => _PrijavaPageState();
}

class _PrijavaPageState extends State<PrijavaPage> {
  // Kontroleri koji "hvataju" tekst iz polja
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Funkcija za prijavu na Firebase
  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Ako uspe, vrati korisnika nazad ili na Dashboard
      Navigator.pop(context); 
    } on FirebaseAuthException catch (e) {
      // Ako pogreši lozinku ili email, izbaci poruku
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.message}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prijava"), backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 30),
            
            // EMAIL POLJE
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email adresa',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            // LOZINKA POLJE
            TextField(
              controller: _passwordController,
              obscureText: true, // Sakriva kucanje lozinke
              decoration: InputDecoration(
                labelText: 'Lozinka',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),

            // DUGME ZA PRIJAVU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Prijavi se", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // LINK ZA REGISTRACIJU
            TextButton(
              onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistracijaPage()),
                );
              },
              child: const Text("Nemaš nalog? Registruj se ovde"),
            ),
          ],
        ),
      ),
    );
  }
}