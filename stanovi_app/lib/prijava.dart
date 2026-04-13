import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registracija.dart';

class PrijavaPage extends StatefulWidget {
  const PrijavaPage({super.key});

  @override
  State<PrijavaPage> createState() => _PrijavaPageState();
}

class _PrijavaPageState extends State<PrijavaPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _adminMode = false; // da li je admin mod aktivan

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.message}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF0F6), Color(0xFFD6E0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF2F5D8C)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // Ikona se menja zavisno od moda
                        Icon(
                          _adminMode ? Icons.admin_panel_settings : Icons.home_work,
                          size: 70,
                          color: _adminMode ? Colors.redAccent : const Color(0xFF2F5D8C),
                        ),
                        const SizedBox(height: 15),

                        Text(
                          _adminMode ? "Admin prijava" : "Prijava",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),

                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Lozinka",
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Glavno dugme
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _adminMode ? Colors.redAccent : const Color(0xFF2F5D8C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              _adminMode ? "Prijavi se kao Admin" : "Prijavi se",
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Dugme za prebacivanje na admin mod
                        if (!_adminMode)
                          TextButton.icon(
                            onPressed: () => setState(() => _adminMode = true),
                            icon: const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
                            label: const Text(
                              "Prijavi se kao Admin",
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),

                        // Dugme za povratak na korisnik mod
                        if (_adminMode)
                          TextButton(
                            onPressed: () => setState(() => _adminMode = false),
                            child: const Text(
                              "Nazad na korisničku prijavu",
                              style: TextStyle(color: Color(0xFF2F5D8C)),
                            ),
                          ),

                        if (!_adminMode)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegistracijaPage()),
                              );
                            },
                            child: const Text(
                              "Nemaš nalog? Registruj se",
                              style: TextStyle(color: Color(0xFF2F5D8C), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}