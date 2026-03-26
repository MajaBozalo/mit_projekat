import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'prijava.dart';
import 'detalji_stan.dart';
import 'profil.dart';
import 'favoritesPage.dart';

class GostPage extends StatelessWidget {
  const GostPage({super.key});

  static final TextEditingController naslovController = TextEditingController();
  static final TextEditingController cenaController = TextEditingController();
  static final TextEditingController slikaController = TextEditingController();
  static final TextEditingController kvadraturaController = TextEditingController();
  static final TextEditingController lokacijaController = TextEditingController();
  static final TextEditingController opisController = TextEditingController();
  static final TextEditingController sobeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final bool jeUlogovan = authSnapshot.hasData;
        final User? user = authSnapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F7), // background za celu stranicu
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF2F5D8C)),
                  child: Text(
                    "Moj meni",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text("Favoriti"),
                  onTap: () {
                    if (!jeUlogovan) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Uloguj se kao korisnik da vidiš favorite!'),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoritesPage()),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profil"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Odjava"),
                  onTap: () {
                    if (jeUlogovan) {
                      FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Uspešno ste se odjavili!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prijavite se!')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: const Text("Stanovi", style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              jeUlogovan
                  ? IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.blueAccent),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrijavaPage()),
                        );
                      },
                    ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('stanovi').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Greška!"));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Trenutno nema stanova."));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var stan = doc.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetaljiStanPage(stan: stan),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  stan['imageUrl'] ?? '',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                              ),
                              if (jeUlogovan)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('favoriti')
                                        .doc(user!.uid)
                                        .snapshots(),
                                    builder: (context, favSnapshot) {
                                      final stanoviFav = favSnapshot.data?.get('stanovi') ?? [];
                                      final jeFavorit = stanoviFav.contains(doc.id);

                                      return GestureDetector(
                                        onTap: () async {
                                          final favDoc = FirebaseFirestore.instance
                                              .collection('favoriti')
                                              .doc(user.uid);

                                          if (jeFavorit) {
                                            await favDoc.update({
                                              'stanovi': FieldValue.arrayRemove([doc.id])
                                            });
                                          } else {
                                            await favDoc.set({
                                              'stanovi': FieldValue.arrayUnion([doc.id])
                                            }, SetOptions(merge: true));
                                          }
                                        },
                                        child: Icon(
                                          jeFavorit ? Icons.favorite : Icons.favorite_border,
                                          color: jeFavorit ? Colors.red : Colors.white,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stan['naslov'] ?? 'Bez naslova',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Cena: ${stan['cena'] ?? ''}",
                                  style: const TextStyle(
                                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                ),
                                Text("Lokacija: ${stan['lokacija'] ?? ''}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: jeUlogovan
              ? FloatingActionButton(
                  backgroundColor: const Color(0xFF2F5D8C),
                  onPressed: () => _prikaziFormuZaDodavanje(context),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  void _prikaziFormuZaDodavanje(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Dodaj novi oglas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(controller: naslovController, decoration: const InputDecoration(labelText: "Naslov")),
              TextField(controller: cenaController, decoration: const InputDecoration(labelText: "Cena")),
              TextField(controller: lokacijaController, decoration: const InputDecoration(labelText: "Lokacija")),
              TextField(controller: kvadraturaController, decoration: const InputDecoration(labelText: "Kvadratura")),
              TextField(controller: sobeController, decoration: const InputDecoration(labelText: "Broj soba")),
              TextField(controller: slikaController, decoration: const InputDecoration(labelText: "URL slike")),
              TextField(controller: opisController, decoration: const InputDecoration(labelText: "Opis"), maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (naslovController.text.isEmpty ||
                      cenaController.text.isEmpty ||
                      lokacijaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Popuni obavezna polja!')),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('stanovi').add({
                    'naslov': naslovController.text,
                    'cena': cenaController.text,
                    'lokacija': lokacijaController.text,
                    'kvadratura': kvadraturaController.text,
                    'sobe': sobeController.text,
                    'imageUrl': slikaController.text,
                    'opis': opisController.text,
                    'vremeObjave': FieldValue.serverTimestamp(),
                  });

                  naslovController.clear();
                  cenaController.clear();
                  lokacijaController.clear();
                  kvadraturaController.clear();
                  sobeController.clear();
                  slikaController.clear();
                  opisController.clear();

                  Navigator.pop(context);
                },
                child: const Text("Objavi oglas"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}