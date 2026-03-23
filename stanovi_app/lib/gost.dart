import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'prijava.dart';

class GostPage extends StatelessWidget {
  const GostPage({super.key});

  // Kontroleri za unos podataka
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

        return Scaffold(
            drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [

      DrawerHeader(
        decoration: BoxDecoration(
          color: Color(0xFF2F5D8C),
        ),
        child: Text(
          "Moj meni",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),

      ListTile(
        leading: Icon(Icons.favorite),
        title: Text("Favoriti"),
        onTap: () {
          // otvara stranicu sa favoritima
        },
      ),

      ListTile(
        leading: Icon(Icons.home),
        title: Text("Moji oglasi"),
        onTap: () {},
      ),

      ListTile(
        leading: Icon(Icons.person),
        title: Text("Profil"),
        onTap: () {},
      ),

      ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text("Odjava"),
        onTap: () {
          FirebaseAuth.instance.signOut();
        },
      ),
    ],
  ),
),
          backgroundColor: const Color(0xFFF5F5F7),
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

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var stan = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slika stana
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            stan['imageUrl'] ?? '',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stan['naslov'] ?? 'Bez naslova',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text("Cena: ${stan['cena'] ?? 'Dogovor'}",
                                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                              Text("Lokacija: ${stan['lokacija'] ?? 'Nepoznato'}"),
                              Text("Kvadratura: ${stan['kvadratura'] ?? '0'} m² | Sobe: ${stan['sobe'] ?? '0'}"),
                              const Divider(),
                              Text(stan['opis'] ?? 'Nema opisa', style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                        // Dugme za komentare (samo za ulogovane)
                        if (jeUlogovan)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.comment_outlined),
                              onPressed: () => _prikaziKomentare(context, doc.id),
                            ),
                          ),
                      ],
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

  // FUNKCIJA ZA DODAVANJE STANA
  void _prikaziFormuZaDodavanje(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Dodaj novi oglas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(controller: naslovController, decoration: const InputDecoration(labelText: "Naslov")),
              TextField(controller: cenaController, decoration: const InputDecoration(labelText: "Cena")),
              TextField(controller: lokacijaController, decoration: const InputDecoration(labelText: "Lokacija")),
              TextField(controller: kvadraturaController, decoration: const InputDecoration(labelText: "Kvadratura")),
              TextField(controller: sobeController, decoration: const InputDecoration(labelText: "Broj soba")),
              TextField(controller: slikaController, decoration: const InputDecoration(labelText: "URL slike")),
              TextField(controller: opisController, decoration: const InputDecoration(labelText: "Opis"), maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F5D8C)),
                  onPressed: () async {
                    if (naslovController.text.isNotEmpty) {
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
                      // Čišćenje polja
                      naslovController.clear();
                      cenaController.clear();
                      lokacijaController.clear();
                      kvadraturaController.clear();
                      sobeController.clear();
                      slikaController.clear();
                      opisController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Objavi oglas", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // FUNKCIJA ZA KOMENTARE
  void _prikaziKomentare(BuildContext context, String stanId) {
    final TextEditingController komentarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ostavi komentar"),
        content: TextField(
          controller: komentarController,
          decoration: const InputDecoration(hintText: "Napiši nešto..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Odustani")),
          ElevatedButton(
            onPressed: () async {
              if (komentarController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('stanovi')
                    .doc(stanId)
                    .collection('komentari')
                    .add({
                  'tekst': komentarController.text,
                  'korisnik': FirebaseAuth.instance.currentUser?.email,
                  'vreme': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Pošalji"),
          ),
        ],
      ),
    );
  }
}