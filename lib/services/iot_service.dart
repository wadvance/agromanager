import 'dart:math';
import 'dart:async';
import '../models/sensor_data.dart';

enum DataSource { simulation, mqtt, lorawan, all }

class IoTService {
  static final Random _random = Random();
  static Timer? _simulationTimer;
  static List<SensorData> _sensors = [];
  static List<SensorHistory> _history = [];
  static DataSource _dataSource = DataSource.all;
  static int _mqttSensorCount = 0;
  static int _loraSensorCount = 0;

  static List<SensorData> get sensors => _sensors;
  static List<SensorHistory> get history => _history;
  static DataSource get dataSource => _dataSource;
  static int get totalExternalSensors => _mqttSensorCount + _loraSensorCount;

  static void setDataSource(DataSource source) {
    _dataSource = source;
    switch (source) {
      case DataSource.simulation:
        _sensors = _createDefaultSensors();
        break;
      case DataSource.mqtt:
        _sensors = _sensors.where((s) => s.name.startsWith('MQTT')).toList();
        break;
      case DataSource.lorawan:
        _sensors =
            _sensors.where((s) => s.name.startsWith('LoRa')).toList();
        break;
      case DataSource.all:
        _sensors = _createDefaultSensors();
        break;
    }
  }

  static Future<void> initialize() async {
    _sensors = _createDefaultSensors();
  }

  static List<SensorData> _createDefaultSensors() {
    final now = DateTime.now();
    return [
      SensorData(
        name: 'Sensor A1 - Café',
        type: 'soil_moisture',
        value: 45.0,
        unit: '%',
        location: 'Lote Café - Norte',
        batteryLevel: 85,
        isOnline: true,
        timestamp: now,
        minThreshold: 20,
        maxThreshold: 80,
      ),
      SensorData(
        name: 'Sensor A2 - Café',
        type: 'soil_temperature',
        value: 24.5,
        unit: '°C',
        location: 'Lote Café - Norte',
        batteryLevel: 85,
        isOnline: true,
        timestamp: now,
        minThreshold: 10,
        maxThreshold: 35,
      ),
      SensorData(
        name: 'Sensor B1 - Pasto',
        type: 'air_temperature',
        value: 28.0,
        unit: '°C',
        location: 'Potrero Central',
        batteryLevel: 72,
        isOnline: true,
        timestamp: now,
        minThreshold: 5,
        maxThreshold: 40,
      ),
      SensorData(
        name: 'Sensor B2 - Pasto',
        type: 'air_humidity',
        value: 65.0,
        unit: '%',
        location: 'Potrero Central',
        batteryLevel: 72,
        isOnline: true,
        timestamp: now,
        minThreshold: 30,
        maxThreshold: 90,
      ),
      SensorData(
        name: 'Pluviómetro Principal',
        type: 'rain_gauge',
        value: 12.5,
        unit: 'mm',
        location: 'Estación Central',
        batteryLevel: 90,
        isOnline: true,
        timestamp: now,
        maxThreshold: 50,
      ),
      SensorData(
        name: 'Anemómetro',
        type: 'wind_speed',
        value: 3.2,
        unit: 'm/s',
        location: 'Estación Central',
        batteryLevel: 88,
        isOnline: true,
        timestamp: now,
        maxThreshold: 15,
      ),
      SensorData(
        name: 'Sensor C1 - Hortalizas',
        type: 'soil_ph',
        value: 6.5,
        unit: 'pH',
        location: 'Invernadero',
        batteryLevel: 65,
        isOnline: true,
        timestamp: now,
        minThreshold: 5.5,
        maxThreshold: 7.5,
      ),
      SensorData(
        name: 'Radiación Solar',
        type: 'solar_radiation',
        value: 450.0,
        unit: 'W/m²',
        location: 'Estación Central',
        batteryLevel: 80,
        isOnline: true,
        timestamp: now,
        maxThreshold: 1000,
      ),
    ];
  }

  static void updateFromMqtt(SensorData sensor) {
    final idx =
        _sensors.indexWhere((s) => s.name == sensor.name);
    if (idx >= 0) {
      _history.insert(
        0, SensorHistory(value: _sensors[idx].value, timestamp: _sensors[idx].timestamp));
      if (_history.length > 500) _history = _history.sublist(0, 500);
      _sensors[idx] = sensor;
    } else {
      _sensors.add(sensor);
      _mqttSensorCount++;
    }
  }

  static void updateFromExternal(SensorData sensor) {
    final idx =
        _sensors.indexWhere((s) => s.name == sensor.name);
    if (idx >= 0) {
      _history.insert(
        0, SensorHistory(value: _sensors[idx].value, timestamp: _sensors[idx].timestamp));
      if (_history.length > 500) _history = _history.sublist(0, 500);
      _sensors[idx] = sensor;
    } else {
      _sensors.add(sensor);
      _loraSensorCount++;
    }
  }

  static void startSimulation(
      {Duration interval = const Duration(seconds: 30)}) {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(interval, (_) {
      final now = DateTime.now();
      for (var i = 0; i < _sensors.length; i++) {
        final s = _sensors[i];
        if (s.name.startsWith('MQTT') || s.name.startsWith('LoRa') || s.name.startsWith('TTN')) {
          continue;
        }

        final variation = (_random.nextDouble() - 0.5) * 4;
        final newValue = (s.value + variation).clamp(0, 1000);

        _history.insert(
          0,
          SensorHistory(value: s.value, timestamp: s.timestamp),
        );

        if (_history.length > 500) {
          _history = _history.sublist(0, 500);
        }

        _sensors[i] = SensorData(
          id: s.id,
          name: s.name,
          type: s.type,
          value: double.parse(newValue.toStringAsFixed(1)),
          unit: s.unit,
          location: s.location,
          batteryLevel:
              (s.batteryLevel! - _random.nextDouble() * 0.05).clamp(0, 100),
          isOnline: _random.nextDouble() > 0.02,
          timestamp: now,
          minThreshold: s.minThreshold,
          maxThreshold: s.maxThreshold,
        );
      }
    });
  }

  static void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  static Future<void> addSensor(SensorData sensor) async {
    _sensors.add(sensor);
  }

  static Future<void> updateSensor(SensorData sensor) async {
    final idx = _sensors.indexWhere((s) => s.name == sensor.name);
    if (idx >= 0) {
      _sensors[idx] = sensor;
    }
  }

  static Future<void> deleteSensor(String name) async {
    _sensors.removeWhere((s) => s.name == name);
  }

  static List<SensorData> getSensorsByType(String type) {
    return _sensors.where((s) => s.type == type).toList();
  }

  static List<SensorData> getAlertSensors() {
    return _sensors.where((s) => s.isAlert).toList();
  }

  static List<SensorData> getOfflineSensors() {
    return _sensors.where((s) => !s.isOnline).toList();
  }

  static double getAverageByType(String type, String field) {
    final filtered = _sensors.where((s) => s.type == type).toList();
    if (filtered.isEmpty) return 0;
    switch (field) {
      case 'value':
        return filtered.fold(0.0, (s, e) => s + e.value) / filtered.length;
      case 'battery':
        return filtered.fold(0.0, (s, e) => s + (e.batteryLevel ?? 0)) /
            filtered.length;
      default:
        return 0;
    }
  }

  static void dispose() {
    stopSimulation();
  }
}
