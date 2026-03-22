import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'prijava.dart'; // Proveri da li se fajl zove ovako

class GostPage extends StatelessWidget {
  const GostPage({super.key});
  
static final TextEditingController naslovController = TextEditingController();
  static final TextEditingController cenaController = TextEditingController();
  static final TextEditingController slikaController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // KLJUČNO: Slušamo promene u Firebase Auth-u
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Ako u snapshotu imamo podatke, korisnik je ulogovan
        final bool jeUlogovan = authSnapshot.hasData;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          appBar: AppBar(
            title: const Text("Stanovi", style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              // Ako je ulogovan -> pokaži Logout
              // Ako je gost -> pokaži ikonicu za Prijavu/Registraciju
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

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var stan = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    child: Column(
                      children: [
                        // Slika stana
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: stan['imageUrl'] != null 
                            ? Image.network(stan['imageUrl'], height: 180, width: double.infinity, fit: BoxFit.cover)
                            : Container(height: 180, color: Colors.grey[300], child: const Icon(Icons.image)),
                        ),
                        ListTile(
                          title: Text(stan['naslov'] ?? 'Bez naslova', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(stan['cena'] ?? 'Dogovor'),
                          // DODATNA FUNKCIONALNOST: Komentarisanje (samo za ulogovane)
                          trailing: jeUlogovan 
                            ? IconButton(
                                icon: const Icon(Icons.comment_outlined, color: Colors.blueGrey),
                                onPressed: () => _prikaziKomentare(context, snapshot.data!.docs[index].id),
                              ) 
                            : null,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // DODATNA FUNKCIONALNOST: Dugme za dodavanje (samo za ulogovane)
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

  // Mala forma koja iskače odozdo
 void _prikaziFormuZaDodavanje(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
          top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Dodaj novi oglas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextField(controller: naslovController, decoration: const InputDecoration(labelText: "Naslov")),
          TextField(controller: cenaController, decoration: const InputDecoration(labelText: "Cena (npr. 400€)")),
          TextField(controller: slikaController, decoration: const InputDecoration(labelText: "URL slike")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // FUNKCIJA KOJA ŠALJE U FIREBASE
              await FirebaseFirestore.instance.collection('stanovi').add({
                'naslov': naslovController.text,
                'cena': cenaController.text,
                'imageUrl': slikaController.text,
                'vremeObjave': FieldValue.serverTimestamp(),
                'vlasnikId': FirebaseAuth.instance.currentUser?.uid,
              });
              
              // Očisti polja i zatvori prozor
              naslovController.clear();
              cenaController.clear();
              slikaController.clear();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Oglas uspešno dodat!")),
              );
            },
            child: const Text("Objavi"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
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
}}