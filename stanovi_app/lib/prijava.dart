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
  bool _adminMode = false;
  bool _loading = false;
  bool _lozinkaNijePrikazana = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future signIn() async {
    // Validacija praznih polja
    if (_emailController.text.trim().isEmpty) {
      _prikaziGresku("Unesite email!");
      return;
    }

    if (!_emailController.text.trim().contains('@')) {
      _prikaziGresku("Unesite ispravan email!");
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _prikaziGresku("Unesite lozinku!");
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _prikaziGresku("Lozinka mora imati najmanje 6 karaktera!");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String poruka;
      switch (e.code) {
        case 'user-not-found':
          poruka = "Ne postoji nalog sa ovim emailom!";
          break;
        case 'wrong-password':
          poruka = "Pogrešna lozinka!";
          break;
        case 'invalid-email':
          poruka = "Email adresa nije ispravna!";
          break;
        case 'user-disabled':
          poruka = "Ovaj nalog je deaktiviran!";
          break;
        case 'too-many-requests':
          poruka = "Previše pokušaja. Pokušajte kasnije!";
          break;
        case 'invalid-credential':
          poruka = "Pogrešan email ili lozinka!";
          break;
        default:
          poruka = "Pogrešan email ili lozinka!";
      }
      _prikaziGresku(poruka);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _prikaziGresku(String poruka) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(poruka)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool jeAdmin = _adminMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: jeAdmin
                ? [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)]
                : [const Color(0xFFEAF0F6), const Color(0xFFD6E0F0)],
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
                  elevation: 16,
                  shadowColor: jeAdmin
                      ? Colors.redAccent.withOpacity(0.3)
                      : const Color(0xFF2F5D8C).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nazad dugme
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // Avatar ikona
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: jeAdmin
                                ? Colors.redAccent.withOpacity(0.1)
                                : const Color(0xFF2F5D8C).withOpacity(0.1),
                          ),
                          child: Icon(
                            jeAdmin ? Icons.admin_panel_settings : Icons.home_work,
                            size: 50,
                            color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Naslov
                        Text(
                          jeAdmin ? "Admin prijava" : "Prijava",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                          ),
                        ),

                        // Podnaslov
                        Text(
                          jeAdmin
                              ? "Pristup administratorskom panelu"
                              : "Dobrodošli nazad!",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Email polje
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "primjer@email.com",
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Lozinka polje
                        TextField(
                          controller: _passwordController,
                          obscureText: _lozinkaNijePrikazana,
                          decoration: InputDecoration(
                            labelText: "Lozinka",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _lozinkaNijePrikazana
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _lozinkaNijePrikazana = !_lozinkaNijePrikazana),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Prijavi se dugme
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  jeAdmin ? Colors.redAccent : const Color(0xFF2F5D8C),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    jeAdmin ? "Prijavi se kao Admin" : "Prijavi se",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text("ili", style: TextStyle(color: Colors.grey[400])),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Prebaci mod
                        if (!jeAdmin)
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _adminMode = true;
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            icon: const Icon(Icons.admin_panel_settings,
                                color: Colors.redAccent, size: 18),
                            label: const Text(
                              "Prijavi se kao Admin",
                              style: TextStyle(
                                  color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),

                        if (jeAdmin)
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _adminMode = false;
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            icon: const Icon(Icons.person_outline,
                                color: Color(0xFF2F5D8C), size: 18),
                            label: const Text(
                              "Nazad na korisničku prijavu",
                              style: TextStyle(color: Color(0xFF2F5D8C)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2F5D8C)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),

                        // Registracija
                        if (!jeAdmin) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Nemaš nalog?",
                                  style: TextStyle(color: Colors.grey[600])),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const RegistracijaPage()),
                                  );
                                },
                                child: const Text(
                                  "Registruj se",
                                  style: TextStyle(
                                    color: Color(0xFF2F5D8C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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