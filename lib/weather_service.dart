import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = "api.openweathermap.org";

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    city = city.trim();
    if (city.isEmpty) throw Exception("Ciudad vacía");

    /// ✅ Se asegura cargar key desde .env
    final apiKey = dotenv.env["OPENWEATHER_API_KEY"];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API Key no configurada");
    }

    final uri = Uri.https(
      _baseUrl,
      "/data/2.5/weather",
      {
        "q": "$city,MX",
        "appid": apiKey,
        "units": "metric",
        "lang": "es",
      },
    );

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else if (resp.statusCode == 404) {
        throw Exception("Ciudad no encontrada");
      } else if (resp.statusCode == 401) {
        throw Exception("API Key inválida");
      } else if (resp.statusCode == 429) {
        throw Exception("Límite de peticiones excedido");
      } else {
        throw Exception("Error: ${resp.statusCode}");
      }
    } catch (_) {
      rethrow;
    }
  }
}
