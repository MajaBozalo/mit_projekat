import 'package:flutter/material.dart';

class DetaljiStanPage extends StatelessWidget {
  final Map<String, dynamic> stan;

  const DetaljiStanPage({super.key, required this.stan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stan['naslov'] ?? "Stan"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // slika
            Image.network(
              stan['imageUrl'] ?? '',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    stan['naslov'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Cena: ${stan['cena'] ?? 'Dogovor'}",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("Lokacija: ${stan['lokacija'] ?? ''}"),
                  Text("Kvadratura: ${stan['kvadratura'] ?? ''} m²"),
                  Text("Broj soba: ${stan['sobe'] ?? ''}"),

                  const SizedBox(height: 20),

                  const Text(
                    "Opis",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    stan['opis'] ?? 'Nema opisa',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}