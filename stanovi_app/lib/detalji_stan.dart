import 'package:flutter/material.dart';

class DetaljiStanPage extends StatelessWidget {
  final Map<String, dynamic> stan;

  const DetaljiStanPage({super.key, required this.stan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(stan['naslov'] ?? "Stan"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SLika
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
              child: stan['imageUrl'] != null && stan['imageUrl'] != ''
                  ? Image.network(
                      stan['imageUrl'],
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(Icons.home, size: 60, color: Colors.grey),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // NASLOV
                  Text(
                    stan['naslov'] ?? 'Bez naslova',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // CIJENA
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Cijena: ${stan['cena'] ?? 'Dogovor'} €",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // INFO KARTICE
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _infoCard(Icons.location_on,
                          stan['lokacija'] ?? 'Nepoznato'),
                      _infoCard(Icons.square_foot,
                          "${stan['kvadratura'] ?? '-'} m²"),
                      _infoCard(Icons.bed,
                          "${stan['sobe'] ?? '-'} sobe"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Opis",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    stan['opis'] ?? 'Nema opisa',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}