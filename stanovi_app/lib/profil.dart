import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Svi korisnici")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('korisnici').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final int userID = int.tryParse(user['userID'].toString()) ?? 1;
              final bool jeAdmin = userID == 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: jeAdmin ? Colors.redAccent : Colors.blueAccent,
                  child: Icon(
                    jeAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      "${user['ime'] ?? 'Nepoznato'} ${user['prezime'] ?? ''}",
                    ),
                    if (jeAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Admin",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(user['email'] ?? "Nema emaila"),
              );
            },
          );
        },
      ),
    );
  }
}