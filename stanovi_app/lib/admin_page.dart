import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalji_stan.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          "Admin Panel",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stanovi').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Trenutno nema stanova."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.60, // ✔ OSTAVLJENO KAKO SI TRAŽILA
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var stan = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        stan['imageUrl'] ?? '',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          );
                        },
                      ),
                    ),

                    // INFO
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              stan['naslov'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              "Cena: ${stan['cena'] ?? ''}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.blueAccent, fontSize: 12),
                            ),
                            Text(
                              "Lokacija: ${stan['lokacija'] ?? ''}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // BUTTONS (FIX ZA HORIZONTAL OVERFLOW)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetaljiStanPage(stan: stan),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.orange),
                              onPressed: () => _prikaziFormuZaIzmenu(
                                  context, doc.id, stan),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _potvrdiiBrisanje(context, doc.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _prikaziFormuZaDodavanje(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // DELETE
  void _potvrdiiBrisanje(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Obriši stan"),
        content: const Text("Da li si siguran?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('stanovi')
                  .doc(docId)
                  .delete();

              Navigator.pop(context);
            },
            child: const Text("Obriši"),
          ),
        ],
      ),
    );
  }

  // EDIT (ostaje isto)
  void _prikaziFormuZaIzmenu(
      BuildContext context, String docId, Map<String, dynamic> stan) {
    final naslovController = TextEditingController(text: stan['naslov']);
    final cenaController = TextEditingController(text: stan['cena']);
    final lokacijaController = TextEditingController(text: stan['lokacija']);
    final kvadraturaController =
        TextEditingController(text: stan['kvadratura']);
    final sobeController = TextEditingController(text: stan['sobe']);
    final slikaController = TextEditingController(text: stan['imageUrl']);
    final opisController = TextEditingController(text: stan['opis']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: naslovController),
              TextField(controller: cenaController),
              TextField(controller: lokacijaController),
              TextField(controller: kvadraturaController),
              TextField(controller: sobeController),
              TextField(controller: slikaController),
              TextField(controller: opisController),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('stanovi')
                      .doc(docId)
                      .update({
                    'naslov': naslovController.text,
                    'cena': cenaController.text,
                    'lokacija': lokacijaController.text,
                    'kvadratura': kvadraturaController.text,
                    'sobe': sobeController.text,
                    'imageUrl': slikaController.text,
                    'opis': opisController.text,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Sačuvaj"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CREATE (ostaje isto)
  void _prikaziFormuZaDodavanje(BuildContext context) {
    final naslovController = TextEditingController();
    final cenaController = TextEditingController();
    final lokacijaController = TextEditingController();
    final kvadraturaController = TextEditingController();
    final sobeController = TextEditingController();
    final slikaController = TextEditingController();
    final opisController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: naslovController),
              TextField(controller: cenaController),
              TextField(controller: lokacijaController),
              TextField(controller: kvadraturaController),
              TextField(controller: sobeController),
              TextField(controller: slikaController),
              TextField(controller: opisController),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('stanovi').add({
                    'naslov': naslovController.text,
                    'cena': cenaController.text,
                    'lokacija': lokacijaController.text,
                    'kvadratura': kvadraturaController.text,
                    'sobe': sobeController.text,
                    'imageUrl': slikaController.text,
                    'opis': opisController.text,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Objavi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}