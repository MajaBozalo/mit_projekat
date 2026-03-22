import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GostPage extends StatelessWidget {
  const GostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Moderna svetlo-siva pozadina
      appBar: AppBar(
        title: const Text(
          "Dostupni Stanovi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.blueAccent, size: 30),
              onPressed: () {
                // Ovde ćemo kasnije staviti navigaciju:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthPage()));
                print("Kliknuto na Login");
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        // Slušamo kolekciju 'stanovi' (ili 'apartments' zavisno kako si nazvala u Firebase-u)
        stream: FirebaseFirestore.instance.collection('stanovi').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Došlo je do greške pri učitavanju."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Trenutno nema stanova u ponudi."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var stan = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: Colors.black26,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SLIKA STANA
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: stan['imageUrl'] != null
                          ? Image.network(
                              stan['imageUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            )
                          : Container(
                              height: 200,
                              color: Colors.blue[50],
                              child: const Icon(Icons.image, size: 50, color: Colors.blue),
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. NASLOV I CENA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  stan['naslov'] ?? 'Bez naslova',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "${stan['cena'] ?? 'Dogovor'}",
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.blueAccent
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 3. LOKACIJA
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              Text(
                                stan['lokacija'] ?? 'Lokacija nije navedena',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 4. OPIS
                          Text(
                            stan['opis'] ?? 'Nema dodatnog opisa za ovaj stan.',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[800], height: 1.4),
                          ),
                          
                          const Divider(height: 30),

                          // 5. DODATNI DETALJI (SOBE/KVADRATURA)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.king_bed_outlined, size: 20, color: Colors.blueGrey),
                              const SizedBox(width: 5),
                              Text("${stan['sobe'] ?? 'N/A'} sobe", style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 20),
                              const Icon(Icons.square_foot, size: 20, color: Colors.blueGrey),
                              const SizedBox(width: 5),
                              Text("${stan['kvadratura'] ?? 'N/A'} m²", style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}