import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'theme_provider.dart';
import 'help_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // 🔥 FUNKCIJA IDE OVDJE (IZVAN build!)
  void _prikaziPrijavuProblema(BuildContext context) {
    final TextEditingController problemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prijavi problem"),
        content: TextField(
          controller: problemController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Opiši problem...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (problemController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('problemi').add({
                  'opis': problemController.text,
                  'vreme': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Problem poslat ✔️"),
                  ),
                );
              }
            },
            child: const Text("Pošalji"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Postavke"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🌙 DARK MODE
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: SwitchListTile(
              title: const Text("Tamni režim (Dark Mode)"),
              subtitle: const Text("Prilagodi izgled ekrana"),
              secondary: Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color:
                    themeProvider.isDarkMode ? Colors.orange : Colors.blue,
              ),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
              },
            ),
          ),

          // ❓ HELP CENTAR
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Help centar"),
              subtitle: const Text("Pomoć i podrška"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpPage(),
                  ),
                );
              },
            ),
          ),

          // 🐞 PRIJAVI PROBLEM (DIREKTNO IZ SETTINGS)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text("Prijavi problem"),
              subtitle: const Text("Pošalji feedback"),
              onTap: () {
                _prikaziPrijavuProblema(context);
              },
            ),
          ),

          const Spacer(),

          // ℹ️ VERZIJA
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "Verzija 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}