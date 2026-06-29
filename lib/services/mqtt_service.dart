import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor_data.dart';
import 'iot_service.dart';

class MqttConfig {
  String broker;
  int port;
  String clientId;
  String? username;
  String? password;
  bool useTls;
  List<String> topics;

  MqttConfig({
    this.broker = 'broker.hivemq.com',
    this.port = 1883,
    this.clientId = 'agromanager_001',
    this.username,
    this.password,
    this.useTls = false,
    this.topics = const [
      'agromanager/sensors/soil_moisture',
      'agromanager/sensors/temperature',
      'agromanager/sensors/humidity',
      'agromanager/sensors/rain',
      'agromanager/sensors/wind',
      'agromanager/sensors/ph',
      'agromanager/sensors/+/+',
    ],
  });

  Map<String, dynamic> toMap() => {
        'broker': broker,
        'port': port,
        'clientId': clientId,
        'username': username ?? '',
        'password': password ?? '',
        'useTls': useTls,
        'topics': topics,
      };

  factory MqttConfig.fromMap(Map<String, dynamic> map) => MqttConfig(
        broker: map['broker'] as String? ?? 'broker.hivemq.com',
        port: map['port'] as int? ?? 1883,
        clientId: map['clientId'] as String? ?? 'agromanager_001',
        username: map['username'] as String?,
        password: map['password'] as String?,
        useTls: map['useTls'] as bool? ?? false,
        topics: (map['topics'] as List?)?.cast<String>() ?? [],
      );
}

class MqttService {
  static MqttServerClient? _client;
  static MqttConfig _config = MqttConfig();
  static bool _isConnected = false;
  static StreamSubscription? _subscription;
  static final List<SensorData> _receivedData = [];
  static int _messagesReceived = 0;

  static MqttConfig get config => _config;
  static bool get isConnected => _isConnected;
  static List<SensorData> get receivedData => _receivedData;
  static int get messagesReceived => _messagesReceived;

  static void updateConfig(MqttConfig newConfig) {
    _config = newConfig;
  }

  static Future<bool> connect() async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      _client = MqttServerClient(_config.broker, _config.clientId);
      _client!.port = _config.port;
      _client!.keepAlivePeriod = 60;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_config.clientId)
          .withWillTopic('willtopic')
          .withWillMessage('AgroManager disconnected')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      if (_config.username != null && _config.username!.isNotEmpty) {
        connMessage.authenticateAs(_config.username!, _config.password ?? '');
      }

      _client!.connectionMessage = connMessage;
      await _client!.connect();

      if (_client!.connectionStatus?.state ==
          MqttConnectionState.connected) {
        _isConnected = true;

        for (final topic in _config.topics) {
          _client!.subscribe(topic, MqttQos.atLeastOnce);
        }

        _subscription = _client!.updates?.listen(_onMessage);
        return true;
      }

      await disconnect();
      return false;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  static Future<void> disconnect() async {
    _subscription?.cancel();
    _client?.disconnect();
    _client = null;
    _isConnected = false;
  }

  static Future<void> publish(String topic, String message) async {
    if (!_isConnected || _client == null) return;

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  static void _onConnected() {
    _isConnected = true;
  }

  static void _onDisconnected() {
    _isConnected = false;
  }

  static void _onSubscribed(String topic) {}

  static void _onMessage(List<MqttReceivedMessage<MqttMessage?>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final payload = msg.payload as MqttPublishMessage;
      final bytes = payload.payload.message as List<int>;
      final message = utf8.decode(bytes);

      _messagesReceived++;
      _processMessage(topic, message);
    }
  }

  static void _processMessage(String topic, String message) {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      final sensor = _parseSensorData(topic, data);
      if (sensor != null) {
        _receivedData.add(sensor);
        if (_receivedData.length > 100) {
          _receivedData.removeAt(0);
        }
        IoTService.updateFromMqtt(sensor);
      }
    } catch (_) {
      try {
        final value = double.tryParse(message.trim());
        if (value != null) {
          final sensor = _parseSimpleValue(topic, value);
          if (sensor != null) {
            _receivedData.add(sensor);
            if (_receivedData.length > 100) {
              _receivedData.removeAt(0);
            }
            IoTService.updateFromMqtt(sensor);
          }
        }
      } catch (_) {}
    }
  }

  static SensorData? _parseSensorData(
      String topic, Map<String, dynamic> data) {
    final sensorType = _topicToType(topic);
    if (sensorType == null) return null;

    final value = (data['value'] ?? data['valor']) as num?;
    if (value == null) return null;

    return SensorData(
      name: data['name'] as String? ?? 'MQTT Sensor $topic',
      type: sensorType,
      value: value.toDouble(),
      unit: data['unit'] as String? ?? _defaultUnit(sensorType),
      location: data['location'] as String? ??
          data['ubicacion'] as String? ??
          '',
      batteryLevel: data['battery'] != null
          ? (data['battery'] as num).toDouble()
          : data['bateria'] != null
              ? (data['bateria'] as num).toDouble()
              : null,
      isOnline: true,
      timestamp: DateTime.now(),
      minThreshold: data['min'] != null
          ? (data['min'] as num).toDouble()
          : data['minimo'] != null
              ? (data['minimo'] as num).toDouble()
              : null,
      maxThreshold: data['max'] != null
          ? (data['max'] as num).toDouble()
          : data['maximo'] != null
              ? (data['maximo'] as num).toDouble()
              : null,
    );
  }

  static SensorData? _parseSimpleValue(String topic, double value) {
    final sensorType = _topicToType(topic);
    if (sensorType == null) return null;

    return SensorData(
      name: 'MQTT ${topic.split('/').last}',
      type: sensorType,
      value: value,
      unit: _defaultUnit(sensorType),
      location: topic.split('/').sublist(0, 3).join('/'),
      isOnline: true,
      timestamp: DateTime.now(),
    );
  }

  static String? _topicToType(String topic) {
    final parts = topic.split('/');
    if (parts.length < 3) return null;

    final type = parts.last.toLowerCase();
    switch (type) {
      case 'soil_moisture':
      case 'humedad_suelo':
        return 'soil_moisture';
      case 'soil_temperature':
      case 'temp_suelo':
        return 'soil_temperature';
      case 'temperature':
      case 'temperatura':
      case 'air_temperature':
      case 'temp_ambiente':
        return 'air_temperature';
      case 'humidity':
      case 'humedad':
      case 'air_humidity':
      case 'humedad_ambiente':
        return 'air_humidity';
      case 'rain':
      case 'lluvia':
      case 'rain_gauge':
      case 'pluviometro':
        return 'rain_gauge';
      case 'wind':
      case 'viento':
      case 'wind_speed':
      case 'velocidad_viento':
        return 'wind_speed';
      case 'ph':
        return 'soil_ph';
      case 'ec':
      case 'conductivity':
      case 'conductividad':
      case 'soil_ec':
        return 'soil_ec';
      case 'solar':
      case 'solar_radiation':
      case 'radiacion':
        return 'solar_radiation';
      default:
        return 'unknown';
    }
  }

  static String _defaultUnit(String type) {
    switch (type) {
      case 'soil_moisture':
      case 'air_humidity':
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
      case 'soil_ec':
        return 'µS/cm';
      case 'solar_radiation':
        return 'W/m²';
      default:
        return 'N/A';
    }
  }

  static void dispose() {
    disconnect();
  }
}
