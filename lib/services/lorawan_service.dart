import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import 'iot_service.dart';

class LoraWanConfig {
  String server;
  int port;
  String? apiKey;
  String? applicationId;
  String? deviceEui;
  bool useChirpStack;

  LoraWanConfig({
    this.server = 'localhost',
    this.port = 8080,
    this.apiKey,
    this.applicationId,
    this.deviceEui,
    this.useChirpStack = true,
  });

  Map<String, dynamic> toMap() => {
        'server': server,
        'port': port,
        'apiKey': apiKey ?? '',
        'applicationId': applicationId ?? '',
        'deviceEui': deviceEui ?? '',
        'useChirpStack': useChirpStack,
      };

  factory LoraWanConfig.fromMap(Map<String, dynamic> map) => LoraWanConfig(
        server: map['server'] as String? ?? 'localhost',
        port: map['port'] as int? ?? 8080,
        apiKey: map['apiKey'] as String?,
        applicationId: map['applicationId'] as String?,
        deviceEui: map['deviceEui'] as String?,
        useChirpStack: map['useChirpStack'] as bool? ?? true,
      );
}

class LoraWanService {
  static LoraWanConfig _config = LoraWanConfig();
  static bool _isConnected = false;
  static Timer? _pollTimer;
  static int _messagesReceived = 0;

  static LoraWanConfig get config => _config;
  static bool get isConnected => _isConnected;
  static int get messagesReceived => _messagesReceived;

  static void updateConfig(LoraWanConfig newConfig) {
    _config = newConfig;
  }

  static Future<bool> connect() async {
    if (_config.useChirpStack) {
      return await _connectChirpStack();
    } else {
      return await _connectTTN();
    }
  }

  static Future<bool> _connectChirpStack() async {
    try {
      final url = Uri.parse(
          'http://${_config.server}:${_config.port}/api/applications/${_config.applicationId}');

      final response = await http.get(
        url,
        headers: {
          'Grpc-Metadata-Authorization': 'Bearer ${_config.apiKey ?? ''}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _isConnected = true;
        _startPolling();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _connectTTN() async {
    try {
      final url = Uri.parse(
          'https://${_config.server}/api/v3/applications/${_config.applicationId}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${_config.apiKey ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        _isConnected = true;
        _startPolling();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  static Future<void> _fetchData() async {
    if (_config.useChirpStack) {
      await _fetchChirpStackData();
    } else {
      await _fetchTTNData();
    }
  }

  static Future<void> _fetchChirpStackData() async {
    try {
      final url = Uri.parse(
          'http://${_config.server}:${_config.port}/api/devices/${_config.deviceEui}/queue');

      final response = await http.get(
        url,
        headers: {
          'Grpc-Metadata-Authorization': 'Bearer ${_config.apiKey ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          for (final item in data) {
            _processDevicePayload(item);
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> _fetchTTNData() async {
    try {
      final url = Uri.parse(
          'https://${_config.server}/api/v3/as/applications/${_config.applicationId}/packages/storage/uplink_message');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${_config.apiKey ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          _processTTNPayload(data);
        }
      }
    } catch (_) {}
  }

  static void _processDevicePayload(Map<String, dynamic> payload) {
    _messagesReceived++;

    final fields = payload['object']?['fields'] as Map<String, dynamic>?;
    if (fields == null) return;

    for (final entry in fields.entries) {
      final value = double.tryParse(entry.value.toString());
      if (value != null) {
        final sensor = SensorData(
          name: 'LoRa ${entry.key}',
          type: _mapFieldToType(entry.key),
          value: value,
          unit: _defaultUnit(_mapFieldToType(entry.key)),
          location: 'LoRaWAN Device ${_config.deviceEui}',
          isOnline: true,
          timestamp: DateTime.now(),
        );
        IoTService.updateFromExternal(sensor);
      }
    }
  }

  static void _processTTNPayload(Map<String, dynamic> payload) {
    _messagesReceived++;

    final uplink = payload['uplink_message'] as Map<String, dynamic>?;
    if (uplink == null) return;

    final decoded = uplink['decoded_payload'] as Map<String, dynamic>?;
    if (decoded == null) return;

    for (final entry in decoded.entries) {
      final value = double.tryParse(entry.value.toString());
      if (value != null) {
        final sensor = SensorData(
          name: 'TTN ${entry.key}',
          type: _mapFieldToType(entry.key),
          value: value,
          unit: _defaultUnit(_mapFieldToType(entry.key)),
          location: 'TTN Device ${_config.deviceEui}',
          isOnline: true,
          timestamp: DateTime.now(),
        );
        IoTService.updateFromExternal(sensor);
      }
    }
  }

  static String _mapFieldToType(String field) {
    final f = field.toLowerCase();
    if (f.contains('humedad') || f.contains('moisture') || f.contains('hum')) {
      return 'soil_moisture';
    }
    if (f.contains('temp')) {
      return 'soil_temperature';
    }
    if (f.contains('ph')) {
      return 'soil_ph';
    }
    if (f.contains('lluvia') || f.contains('rain') || f.contains('pluv')) {
      return 'rain_gauge';
    }
    if (f.contains('viento') || f.contains('wind')) {
      return 'wind_speed';
    }
    if (f.contains('sol') || f.contains('radiation') || f.contains('radiacion')) {
      return 'solar_radiation';
    }
    return 'unknown';
  }

  static String _defaultUnit(String type) {
    switch (type) {
      case 'soil_moisture':
        return '%';
      case 'soil_temperature':
      case 'air_temperature':
        return '°C';
      case 'rain_gauge':
        return 'mm';
      case 'wind_speed':
        return 'm/s';
      case 'soil_ph':
        return 'pH';
      case 'solar_radiation':
        return 'W/m²';
      default:
        return 'N/A';
    }
  }

  static void stop() {
    _pollTimer?.cancel();
    _isConnected = false;
  }

  static void dispose() {
    stop();
  }
}
