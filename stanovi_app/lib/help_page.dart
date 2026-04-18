import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // 🔥 DODANA FUNKCIJA
  void _prikaziPrijavuProblema(BuildContext context) {
    final TextEditingController problemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prijavi problem"),
        content: TextField(
          controller: problemController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Opiši problem...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (problemController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('problemi').add({
                  'opis': problemController.text,
                  'vreme': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Problem poslat ✔️"),
                  ),
                );
              }
            },
            child: const Text("Pošalji"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help centar"),
      ),
      body: ListView(
        children: [
          // FAQ
          ExpansionTile(
            leading: const Icon(Icons.question_answer),
            title: const Text("Kako da dodam oglas?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Klikni na dugme 'Dodaj oglas' i popuni podatke.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Kako da dodam u favorite?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Klikni na srce na oglasu da ga dodaš u favorite.",
                ),
              ),
            ],
          ),

          const Divider(),

          // KONTAKT
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Kontaktiraj nas"),
            subtitle: const Text("support@stanoviapp.com"),
            onTap: () {},
          ),

          // 🐞 PRIJAVA PROBLEMA (SAD RADI)
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text("Prijavi problem"),
            onTap: () {
              _prikaziPrijavuProblema(context);
            },
          ),
        ],
      ),
    );
  }
}