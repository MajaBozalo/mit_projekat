import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'currency_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetaljiStanPage extends StatefulWidget {
  final Map<String, dynamic> stan;

  const DetaljiStanPage({super.key, required this.stan});

  @override
  State<DetaljiStanPage> createState() => _DetaljiStanPageState();
}

class _DetaljiStanPageState extends State<DetaljiStanPage> {
  Map<String, dynamic>? weather;
  bool isLoadingWeather = true;

  double? currencyRsd;
  double? currencyUsd;
  bool isLoadingCurrency = true;

  @override
  void initState() {
    super.initState();
    loadWeather();
    loadCurrency();
  }

  void loadWeather() async {
    try {
      final service = WeatherService();
      // Sigurno izvlačenje grada
      final grad = widget.stan['lokacija']?.toString().split(',').first ?? "Belgrade";
      final data = await service.getWeather(grad);

      if (mounted) {
        setState(() {
          weather = data;
          isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingWeather = false);
      print("Weather error: $e");
    }
  }

  void loadCurrency() async {
    try {
      final service = CurrencyService();
      // Sigurno parsiranje cene bez obzira da li je int ili double
      final price = double.tryParse(widget.stan['cena'].toString()) ?? 0.0;

      final rsd = await service.convert("EUR", "RSD", price);
      final usd = await service.convert("EUR", "USD", price);

      if (mounted) {
        setState(() {
          currencyRsd = rsd;
          currencyUsd = usd;
          isLoadingCurrency = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingCurrency = false);
      print("Currency error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sigurno izvlačenje koordinata
    final double lat = double.tryParse(widget.stan['lat']?.toString() ?? "43.58") ?? 43.58;
    final double lng = double.tryParse(widget.stan['lng']?.toString() ?? "21.33") ?? 21.33;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.stan['naslov'] ?? "Detalji nekretnine"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 SLIKA SA ZAOKRUŽENIM IVICAMA (OPCIONO)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: (widget.stan['imageUrl'] != null && widget.stan['imageUrl'] != '')
                      ? Image.network(widget.stan['imageUrl'], fit: BoxFit.cover)
                      : const Icon(Icons.apartment, size: 80, color: Colors.grey),
                ),
                // Gradijent preko slike da se tekst bolje vidi ako ga dodaš
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stan['naslov'] ?? 'Bez naslova',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // 💰 SEKCIJA ZA CENU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.stan['cena']} €",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueAccent),
                      ),
                      if (!isLoadingCurrency)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${currencyRsd?.toStringAsFixed(0)} RSD", style: const TextStyle(color: Colors.grey)),
                            Text("${currencyUsd?.toStringAsFixed(0)} USD", style: const TextStyle(color: Colors.grey)),
                          ],
                        )
                      else
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),

                  const Divider(height: 30),

                  // 📊 OSNOVNE INFORMACIJE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoIcon(Icons.square_foot, "${widget.stan['kvadratura']} m²"),
                      _infoIcon(Icons.bed, "${widget.stan['sobe']} Sobe"),
                      _infoIcon(Icons.location_city, widget.stan['lokacija'] ?? "N/A"),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 🌦 VRIJEME - Moderniji prikaz
                  const Text("Lokalna prognoza", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _weatherWidget(),

                  const SizedBox(height: 25),

                  // 🗺 MAPA
                  const Text("Lokacija na mapi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      height: 220,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
                        markers: {
                          Marker(
                            markerId: const MarkerId("stan"),
                            position: LatLng(lat, lng),
                            infoWindow: InfoWindow(title: widget.stan['naslov']),
                          ),
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // OPIS
                  const Text("Opis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.stan['opis'] ?? 'Nema dodatnog opisa za ovaj oglas.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _weatherWidget() {
    if (isLoadingWeather) return const Center(child: CircularProgressIndicator());
    if (weather == null) return const Text("Vremenski podaci nedostupni");

    final temp = weather!['main']['temp'].toStringAsFixed(1);
    final desc = weather!['weather'][0]['description'];
    final iconCode = weather!['weather'][0]['icon'];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.network("http://openweathermap.org/img/wn/$iconCode@2x.png", width: 50),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$temp°C", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(desc[0].toUpperCase() + desc.substring(1), style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}