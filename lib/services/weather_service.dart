import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/weather_data.dart';

class WeatherService {
  static Future<WeatherData> getCurrentWeather({
    double? lat,
    double? lon,
  }) async {
    final latitude = lat ?? AppConstants.chiriquiLat;
    final longitude = lon ?? AppConstants.chiriquiLng;

    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}/weather'
      '?lat=$latitude&lon=$longitude'
      '&appid=${AppConstants.weatherApiKey}'
      '&units=metric&lang=es',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener el clima: ${response.statusCode}');
    }

    return WeatherData.fromJson(json.decode(response.body));
  }

  static Future<List<HourlyForecast>> getHourlyForecast({
    double? lat,
    double? lon,
  }) async {
    final latitude = lat ?? AppConstants.chiriquiLat;
    final longitude = lon ?? AppConstants.chiriquiLng;

    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}/forecast'
      '?lat=$latitude&lon=$longitude'
      '&appid=${AppConstants.weatherApiKey}'
      '&units=metric&lang=es&cnt=8',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener pronóstico: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final list = data['list'] as List;
    return list.map((e) => HourlyForecast.fromJson(e)).toList();
  }

  static List<DailyForecast> aggregateDailyForecast(
      List<HourlyForecast> hourly) {
    final Map<String, List<HourlyForecast>> grouped = {};

    for (var h in hourly) {
      final key =
          '${h.time.year}-${h.time.month.toString().padLeft(2, '0')}-${h.time.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(h);
    }

    return grouped.entries.map((entry) {
      final temps = entry.value.map((e) => e.temperature).toList();
      final midDay = entry.value
          .reduce((a, b) =>
              (a.time.hour - 12).abs() < (b.time.hour - 12).abs() ? a : b);

      return DailyForecast(
        date: entry.value.first.time,
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        icon: midDay.icon,
        description: midDay.description,
        humidity: 0,
        windSpeed: 0,
      );
    }).toList();
  }
}
