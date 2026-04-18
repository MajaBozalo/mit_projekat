import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "c466e016bd265d79955d8a68a113173f";

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=sr";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Greška pri učitavanju vremena");
    }
  }
}