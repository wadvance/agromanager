class SensorData {
  final int? id;
  final String name;
  final String type;
  final double value;
  final String unit;
  final String location;
  final double? batteryLevel;
  final bool isOnline;
  final DateTime timestamp;
  final double? minThreshold;
  final double? maxThreshold;

  SensorData({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    this.location = '',
    this.batteryLevel,
    this.isOnline = true,
    DateTime? timestamp,
    this.minThreshold,
    this.maxThreshold,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isAlert =>
      (minThreshold != null && value < minThreshold!) ||
      (maxThreshold != null && value > maxThreshold!);

  String get typeName {
    switch (type) {
      case 'soil_moisture':
        return 'Humedad del suelo';
      case 'soil_temperature':
        return 'Temp. del suelo';
      case 'air_temperature':
        return 'Temp. ambiente';
      case 'air_humidity':
        return 'Humedad ambiente';
      case 'rain_gauge':
        return 'Pluviómetro';
      case 'wind_speed':
        return 'Velocidad viento';
      case 'wind_direction':
        return 'Dirección viento';
      case 'solar_radiation':
        return 'Radiación solar';
      case 'soil_ph':
        return 'pH del suelo';
      case 'soil_ec':
        return 'Conductividad eléctrica';
      default:
        return type;
    }
  }

  String get iconName {
    switch (type) {
      case 'soil_moisture':
        return 'water_drop';
      case 'soil_temperature':
        return 'thermostat';
      case 'air_temperature':
        return 'thermostat';
      case 'air_humidity':
        return 'water_drop';
      case 'rain_gauge':
        return 'umbrella';
      case 'wind_speed':
        return 'air';
      case 'wind_direction':
        return 'navigation';
      case 'solar_radiation':
        return 'wb_sunny';
      case 'soil_ph':
        return 'science';
      case 'soil_ec':
        return 'bolt';
      default:
        return 'sensors';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'value': value,
        'unit': unit,
        'location': location,
        'batteryLevel': batteryLevel,
        'isOnline': isOnline ? 1 : 0,
        'timestamp': timestamp.toIso8601String(),
        'minThreshold': minThreshold,
        'maxThreshold': maxThreshold,
      };

  factory SensorData.fromMap(Map<String, dynamic> map) => SensorData(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String,
        value: (map['value'] as num).toDouble(),
        unit: map['unit'] as String,
        location: map['location'] as String? ?? '',
        batteryLevel: (map['batteryLevel'] as num?)?.toDouble(),
        isOnline: (map['isOnline'] as int? ?? 1) == 1,
        timestamp: DateTime.parse(map['timestamp'] as String),
        minThreshold: (map['minThreshold'] as num?)?.toDouble(),
        maxThreshold: (map['maxThreshold'] as num?)?.toDouble(),
      );
}

class SensorHistory {
  final double value;
  final DateTime timestamp;

  SensorHistory({required this.value, required this.timestamp});

  Map<String, dynamic> toMap() => {
        'value': value,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SensorHistory.fromMap(Map<String, dynamic> map) => SensorHistory(
        value: (map['value'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}
