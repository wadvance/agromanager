import 'package:flutter/material.dart';
import '../../models/sensor_data.dart';
import '../../services/iot_service.dart';
import '../../services/mqtt_service.dart';
import '../../services/lorawan_service.dart';
import 'mqtt_config_screen.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  @override
  void initState() {
    super.initState();
    IoTService.startSimulation();
  }

  @override
  void dispose() {
    IoTService.stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sensors = IoTService.sensors;
    final alerts = IoTService.getAlertSensors();
    final offline = IoTService.getOfflineSensors();

    final mqttConnected = MqttService.isConnected;
    final loraConnected = LoraWanService.isConnected;
    final hasExternalSource = mqttConnected || loraConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sensores IoT'),
        actions: [
          if (hasExternalSource)
            Container(
              margin: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.circle,
                size: 12,
                color: Colors.green,
              ),
            ),
          if (alerts.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.warning_amber, color: Colors.amber),
                  onPressed: () => _showAlerts(context, alerts),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${alerts.length}',
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MqttConfigScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: sensors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay sensores configurados',
                      style: theme.textTheme.titleMedium),
                  SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => IoTService.initialize(),
                    child: Text('Inicializar sensores'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: EdgeInsets.all(12),
                children: [
                  if (hasExternalSource)
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle, size: 12, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Hardware real conectado',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800)),
                              ],
                            ),
                            SizedBox(height: 4),
                            if (mqttConnected)
                              Text('MQTT: ${MqttService.messagesReceived} mensajes',
                                  style: TextStyle(fontSize: 12)),
                            if (loraConnected)
                              Text('LoRaWAN: ${LoraWanService.messagesReceived} mensajes',
                                  style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  if (offline.isNotEmpty)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.sensors_off, color: Colors.red),
                            SizedBox(width: 8),
                            Text('${offline.length} sensor(es) offline',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ...sensors.map((s) => _sensorCard(context, s)),
                  SizedBox(height: 16),
                  Text('Estadísticas',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _statsGrid(context),
                ],
              ),
            ),
    );
  }

  Widget _sensorCard(BuildContext context, SensorData sensor) {
    final theme = Theme.of(context);
    final isAlert = sensor.isAlert;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: isAlert ? Colors.red.shade50 : null,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isAlert
                        ? Colors.red
                        : sensor.isOnline
                            ? Colors.green
                            : Colors.grey)
                    .withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconFromName(sensor.iconName),
                color: isAlert
                    ? Colors.red
                    : sensor.isOnline
                        ? Colors.green
                        : Colors.grey,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sensor.name,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(sensor.typeName,
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(sensor.location,
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${sensor.value.toStringAsFixed(1)} ${sensor.unit}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAlert ? Colors.red : null,
                  ),
                ),
                if (sensor.batteryLevel != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.battery_std,
                          size: 14,
                          color: sensor.batteryLevel! > 20
                              ? Colors.green
                              : Colors.red),
                      SizedBox(width: 4),
                      Text('${sensor.batteryLevel!.toInt()}%',
                          style: TextStyle(fontSize: 11)),
                    ],
                  ),
                if (!sensor.isOnline)
                  Text('Offline',
                      style: TextStyle(fontSize: 11, color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final soilMoisture =
        IoTService.getAverageByType('soil_moisture', 'value');
    final airTemp = IoTService.getAverageByType('air_temperature', 'value');
    final airHum = IoTService.getAverageByType('air_humidity', 'value');
    final rain =
        IoTService.getAverageByType('rain_gauge', 'value');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _statBox(theme, Icons.water_drop, 'Humedad suelo',
            '${soilMoisture.toStringAsFixed(1)}%', Colors.blue),
        _statBox(theme, Icons.thermostat, 'Temp. ambiente',
            '${airTemp.toStringAsFixed(1)}°C', Colors.orange),
        _statBox(theme, Icons.water, 'Humedad aire',
            '${airHum.toStringAsFixed(1)}%', Colors.lightBlue),
        _statBox(theme, Icons.umbrella, 'Precipitación',
            '${rain.toStringAsFixed(1)} mm', Colors.indigo),
      ],
    );
  }

  Widget _statBox(ThemeData theme, IconData icon, String label,
      String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'water_drop':
        return Icons.water_drop;
      case 'thermostat':
        return Icons.thermostat;
      case 'air':
        return Icons.air;
      case 'umbrella':
        return Icons.umbrella;
      case 'navigation':
        return Icons.navigation;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'science':
        return Icons.science;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.sensors;
    }
  }

  void _showAlerts(BuildContext context, List<SensorData> alerts) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Alertas de sensores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...alerts.map((a) => ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text(a.name),
                subtitle: Text(
                    '${a.value.toStringAsFixed(1)} ${a.unit} fuera de rango'),
              )),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
