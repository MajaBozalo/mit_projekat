import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService { // <-- OVO MORA DA POSTOJI
  Future<double> convert(String from, String to, double amount) async {
    const String mojKljuc = "7a0a60c7e82451840b4a9e4e";
    final url = Uri.parse("https://v6.exchangerate-api.com/v6/$mojKljuc/pair/$from/$to");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        double kurs = jsonResponse['conversion_rate'];
        return amount * kurs;
      }
    } catch (e) {
      print("Greška kod konverzije: $e");
    }
    return amount * 117.2; // Default vrednost
  }
}