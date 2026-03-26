import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalji_stan.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Moji favoriti"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('favoriti').doc(user!.uid).snapshots(),
        builder: (context, favSnapshot) {
          if (favSnapshot.hasError) return const Center(child: Text("Greška!"));
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<dynamic> stanoviFav = favSnapshot.data?.get('stanovi') ?? [];

          if (stanoviFav.isEmpty) {
            return const Center(child: Text("Još nemaš omiljene stanove."));
          }

          // Dohvat stanova koji su favoriti
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('stanovi').snapshots(),
            builder: (context, stanSnapshot) {
              if (stanSnapshot.hasError) return const Center(child: Text("Greška!"));
              if (stanSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filtriranje samo stanova koji su u favoritima
              final stanovi = stanSnapshot.data!.docs
                  .where((doc) => stanoviFav.contains(doc.id))
                  .toList();

              if (stanovi.isEmpty) {
                return const Center(child: Text("Još nemaš omiljene stanove."));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: stanovi.length,
                itemBuilder: (context, index) {
                  var doc = stanovi[index];
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
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(
                              stan['imageUrl'] ?? '',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stan['naslov'] ?? 'Bez naslova', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("Cena: ${stan['cena'] ?? ''}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
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
          );
        },
      ),
    );
  }
}