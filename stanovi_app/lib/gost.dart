import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'prijava.dart';
import 'detalji_stan.dart';
import 'profil.dart';
import 'favoritesPage.dart';

class GostPage extends StatefulWidget {
  const GostPage({super.key});

  @override
  State<GostPage> createState() => _GostPageState();
}

class _GostPageState extends State<GostPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _odabraniGrad = 'Svi';

  final TextEditingController naslovController = TextEditingController();
  final TextEditingController cenaController = TextEditingController();
  final TextEditingController slikaController = TextEditingController();
  final TextEditingController kvadraturaController = TextEditingController();
  final TextEditingController lokacijaController = TextEditingController();
  final TextEditingController opisController = TextEditingController();
  final TextEditingController sobeController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    naslovController.dispose();
    cenaController.dispose();
    slikaController.dispose();
    kvadraturaController.dispose();
    lokacijaController.dispose();
    opisController.dispose();
    sobeController.dispose();
    super.dispose();
  }

  // Čita sve jedinstvene gradove iz Firestorea
  Future<List<String>> _ucitajGradove() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('stanovi').get();
    final gradovi = snapshot.docs
        .map((doc) => (doc.data()['lokacija'] ?? '').toString().trim())
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    gradovi.sort();
    return gradovi;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final bool jeUlogovan = authSnapshot.hasData;
        final User? user = authSnapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          drawer: _buildDrawer(context, jeUlogovan),
          appBar: _buildAppBar(context, jeUlogovan),
          body: Column(
            children: [
              // Search bar + filter sekcija
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          setState(() => _searchText = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Pretraži stanove...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchText = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter chips po gradovima
                    FutureBuilder<List<String>>(
                      future: _ucitajGradove(),
                      builder: (context, snapshot) {
                        final gradovi = ['Svi', ...(snapshot.data ?? [])];
                        return SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: gradovi.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final grad = gradovi[index];
                              final jeOdabran = _odabraniGrad == grad;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _odabraniGrad = grad),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: jeOdabran
                                        ? const Color(0xFF2F5D8C)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: jeOdabran
                                          ? const Color(0xFF2F5D8C)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    grad,
                                    style: TextStyle(
                                      color: jeOdabran
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: jeOdabran
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Grid stanova
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stanovi')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Greška!"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Filtriranje
                    var stanovi = snapshot.data!.docs.where((doc) {
                      final stan = doc.data() as Map<String, dynamic>;
                      final naslov =
                          (stan['naslov'] ?? '').toString().toLowerCase();
                      final lokacija =
                          (stan['lokacija'] ?? '').toString().toLowerCase();
                      final opis =
                          (stan['opis'] ?? '').toString().toLowerCase();

                      final odgovaraSearch = _searchText.isEmpty ||
                          naslov.contains(_searchText) ||
                          lokacija.contains(_searchText) ||
                          opis.contains(_searchText);

                      final odgovaraGrad = _odabraniGrad == 'Svi' ||
                          lokacija.contains(_odabraniGrad.toLowerCase());

                      return odgovaraSearch && odgovaraGrad;
                    }).toList();

                    if (stanovi.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              "Nema rezultata za \"$_searchText\"",
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                builder: (context) =>
                                    DetaljiStanPage(stan: stan),
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
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                      child: Image.network(
                                        stan['imageUrl'] ?? '',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image,
                                              size: 40),
                                        ),
                                      ),
                                    ),
                                    // Grad badge
                                    if ((stan['lokacija'] ?? '').isNotEmpty)
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.55),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.white,
                                                  size: 11),
                                              const SizedBox(width: 3),
                                              Text(
                                                stan['lokacija'],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    // Favorit dugme
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
                                            final stanoviFav = (favSnapshot
                                                        .hasData &&
                                                    favSnapshot.data!.exists)
                                                ? (favSnapshot.data!
                                                        .get('stanovi') ??
                                                    [])
                                                : [];
                                            final jeFavorit =
                                                stanoviFav.contains(doc.id);

                                            return GestureDetector(
                                              onTap: () async {
                                                final favDoc =
                                                    FirebaseFirestore.instance
                                                        .collection('favoriti')
                                                        .doc(user.uid);
                                                if (favSnapshot.hasData &&
                                                    favSnapshot.data!.exists) {
                                                  if (jeFavorit) {
                                                    await favDoc.update({
                                                      'stanovi': FieldValue
                                                          .arrayRemove([doc.id])
                                                    });
                                                  } else {
                                                    await favDoc.update({
                                                      'stanovi': FieldValue
                                                          .arrayUnion([doc.id])
                                                    });
                                                  }
                                                } else {
                                                  await favDoc.set({
                                                    'stanovi': [doc.id]
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.85),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  jeFavorit
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: jeFavorit
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  size: 20,
                                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stan['naslov'] ?? 'Bez naslova',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "€ ${stan['cena'] ?? ''}",
                                        style: const TextStyle(
                                          color: Color(0xFF2F5D8C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if ((stan['kvadratura'] ?? '').isNotEmpty)
                                        Text(
                                          "${stan['kvadratura']} m²  •  ${stan['sobe'] ?? ''} sobe",
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11),
                                        ),
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
              ),
            ],
          ),
          floatingActionButton: jeUlogovan
              ? FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF2F5D8C),
                  onPressed: () => _prikaziFormuZaDodavanje(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Dodaj oglas",
                      style: TextStyle(color: Colors.white)),
                )
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, bool jeUlogovan) {
    return AppBar(
      title: const Text("Stanovi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      actions: [
        jeUlogovan
            ? IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () => FirebaseAuth.instance.signOut(),
                tooltip: "Odjavi se",
              )
            : IconButton(
                icon: const Icon(Icons.account_circle,
                    color: Color(0xFF2F5D8C), size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrijavaPage()),
                  );
                },
                tooltip: "Prijava",
              ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context, bool jeUlogovan) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2F5D8C)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.home_work, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                const Text("Stanovi App",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(
                  jeUlogovan ? "Ulogovani ste" : "Gost korisnik",
                  style: TextStyle(color: Colors.white.withOpacity(0.8),
                      fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.redAccent),
            title: const Text("Favoriti"),
            onTap: () {
              if (!jeUlogovan) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Uloguj se da vidiš favorite!')),
                );
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FavoritesPage()));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Color(0xFF2F5D8C)),
            title: const Text("Korisnici"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilPage())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Odjava"),
            onTap: () {
              if (jeUlogovan) {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Niste prijavljeni!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _prikaziFormuZaDodavanje(BuildContext context) {
    String? naslovError;
    String? cenaError;
    String? lokacijaError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 15),
                const Text("Dodaj novi oglas",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                  controller: naslovController,
                  decoration: InputDecoration(
                    labelText: "Naslov *",
                    errorText: naslovError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cenaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Cena (€) *",
                    errorText: cenaError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lokacijaController,
                  decoration: InputDecoration(
                    labelText: "Lokacija *",
                    errorText: lokacijaError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: kvadraturaController,
                  decoration: InputDecoration(
                    labelText: "Kvadratura (m²)",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: sobeController,
                  decoration: InputDecoration(
                    labelText: "Broj soba",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: slikaController,
                  decoration: InputDecoration(
                    labelText: "URL slike",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: opisController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Opis",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5D8C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      setState(() {
                        naslovError = naslovController.text.isEmpty
                            ? 'Naslov je obavezan'
                            : null;
                        cenaError = cenaController.text.isEmpty
                            ? 'Cena je obavezna'
                            : null;
                        lokacijaError = lokacijaController.text.isEmpty
                            ? 'Lokacija je obavezna'
                            : null;
                      });

                      if (naslovError != null ||
                          cenaError != null ||
                          lokacijaError != null) return;

                      await FirebaseFirestore.instance
                          .collection('stanovi')
                          .add({
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Oglas uspješno objavljen!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text("Objavi oglas",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}