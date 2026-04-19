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
        title: const Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Trenutno nema stanova."));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.60,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var stan = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        stan['imageUrl'] ?? '',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(stan['naslov'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Cena: ${stan['cena'] ?? ''}", maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                          Text("Lokacija: ${stan['lokacija'] ?? ''}", maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blueAccent),
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => DetaljiStanPage(stan: stan))),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _prikaziFormuZaIzmenu(context, doc.id, stan),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _potvrdiiBrisanje(context, doc.id),
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

  void _potvrdiiBrisanje(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Obriši stan"),
        content: const Text("Da li si sigurna da želiš obrisati ovaj oglas?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('stanovi').doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Stan obrisan!"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Obriši", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _prikaziFormuZaIzmenu(BuildContext context, String docId, Map<String, dynamic> stan) {
    final naslovController = TextEditingController(text: stan['naslov']);
    final cenaController = TextEditingController(text: stan['cena']);
    final lokacijaController = TextEditingController(text: stan['lokacija']);
    final kvadraturaController = TextEditingController(text: stan['kvadratura']);
    final sobeController = TextEditingController(text: stan['sobe']);
    final slikaController = TextEditingController(text: stan['imageUrl']);
    final opisController = TextEditingController(text: stan['opis']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 15),
              const Text("Izmeni oglas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(controller: naslovController,
                decoration: InputDecoration(labelText: "Naslov", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: cenaController, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Cena (€)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: lokacijaController,
                decoration: InputDecoration(labelText: "Lokacija", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: kvadraturaController,
                decoration: InputDecoration(labelText: "Kvadratura (m²)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: sobeController,
                decoration: InputDecoration(labelText: "Broj soba", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: slikaController,
                decoration: InputDecoration(labelText: "URL slike", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: opisController, maxLines: 3,
                decoration: InputDecoration(labelText: "Opis", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('stanovi').doc(docId).update({
                      'naslov': naslovController.text,
                      'cena': cenaController.text,
                      'lokacija': lokacijaController.text,
                      'kvadratura': kvadraturaController.text,
                      'sobe': sobeController.text,
                      'imageUrl': slikaController.text,
                      'opis': opisController.text,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Stan izmenjen!"), backgroundColor: Colors.orange),
                    );
                  },
                  child: const Text("Sačuvaj izmene", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 15),
              const Text("Dodaj novi oglas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(controller: naslovController,
                decoration: InputDecoration(labelText: "Naslov *", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: cenaController, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Cena (€) *", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: lokacijaController,
                decoration: InputDecoration(labelText: "Lokacija *", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: kvadraturaController,
                decoration: InputDecoration(labelText: "Kvadratura (m²)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: sobeController,
                decoration: InputDecoration(labelText: "Broj soba", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: slikaController,
                decoration: InputDecoration(labelText: "URL slike", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: opisController, maxLines: 3,
                decoration: InputDecoration(labelText: "Opis", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (naslovController.text.isEmpty || cenaController.text.isEmpty || lokacijaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Naslov, cena i lokacija su obavezni!"), backgroundColor: Colors.red),
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
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Stan dodat!"), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text("Objavi oglas", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}