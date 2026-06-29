class WeatherData {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final int windDeg;
  final double clouds;
  final String description;
  final String icon;
  final String cityName;
  final DateTime timestamp;
  final double lat;
  final double lon;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.clouds,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.timestamp,
    required this.lat,
    required this.lon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      pressure: (main['pressure'] as num).toDouble(),
      windSpeed: (wind['speed'] as num).toDouble(),
      windDeg: wind['deg'] as int? ?? 0,
      clouds: (clouds['all'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      cityName: json['name'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      lat: (json['coord']?['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['coord']?['lon'] as num?)?.toDouble() ?? 0,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  bool get isRaining =>
      description.toLowerCase().contains('lluvia') ||
      description.toLowerCase().contains('rain') ||
      description.toLowerCase().contains('drizzle');

  bool get isCloudy =>
      clouds > 50 ||
      description.toLowerCase().contains('nublado') ||
      description.toLowerCase().contains('cloud');
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String icon;
  final String description;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.description,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (main['temp'] as num).toDouble(),
      icon: weather['icon'] as String,
      description: weather['description'] as String,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String description;
  final int humidity;
  final double windSpeed;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = json['temp'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      tempMin: (temp['min'] as num).toDouble(),
      tempMax: (temp['max'] as num).toDouble(),
      icon: weather['icon'] as String,
      description: weather['description'] as String,
      humidity: json['humidity'] as int? ?? 0,
      windSpeed: (json['speed'] as num?)?.toDouble() ?? 0,
    );
  }
}
