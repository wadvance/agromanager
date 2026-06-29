import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../services/lorawan_service.dart';
import '../../services/iot_service.dart';

class MqttConfigScreen extends StatefulWidget {
  const MqttConfigScreen({super.key});

  @override
  State<MqttConfigScreen> createState() => _MqttConfigScreenState();
}

class _MqttConfigScreenState extends State<MqttConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brokerCtrl;
  late TextEditingController _portCtrl;
  late TextEditingController _clientIdCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _topicsCtrl;
  late TextEditingController _loraServerCtrl;
  late TextEditingController _loraPortCtrl;
  late TextEditingController _loraApiKeyCtrl;
  late TextEditingController _loraAppIdCtrl;
  late TextEditingController _loraDeviceEuiCtrl;
  bool _useMqtt = false;
  bool _useLoRa = false;
  bool _useTls = false;
  bool _isConnecting = false;
  String _connectionStatus = '';
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    final mqttConfig = MqttService.config;
    final loraConfig = LoraWanService.config;

    _brokerCtrl = TextEditingController(text: mqttConfig.broker);
    _portCtrl = TextEditingController(text: mqttConfig.port.toString());
    _clientIdCtrl = TextEditingController(text: mqttConfig.clientId);
    _usernameCtrl = TextEditingController(text: mqttConfig.username ?? '');
    _passwordCtrl = TextEditingController(text: mqttConfig.password ?? '');
    _topicsCtrl =
        TextEditingController(text: mqttConfig.topics.join('\n'));
    _loraServerCtrl =
        TextEditingController(text: loraConfig.server);
    _loraPortCtrl =
        TextEditingController(text: loraConfig.port.toString());
    _loraApiKeyCtrl =
        TextEditingController(text: loraConfig.apiKey ?? '');
    _loraAppIdCtrl =
        TextEditingController(text: loraConfig.applicationId ?? '');
    _loraDeviceEuiCtrl =
        TextEditingController(text: loraConfig.deviceEui ?? '');
    _updateStatus();
  }

  @override
  void dispose() {
    _brokerCtrl.dispose();
    _portCtrl.dispose();
    _clientIdCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _topicsCtrl.dispose();
    _loraServerCtrl.dispose();
    _loraPortCtrl.dispose();
    _loraApiKeyCtrl.dispose();
    _loraAppIdCtrl.dispose();
    _loraDeviceEuiCtrl.dispose();
    super.dispose();
  }

  void _updateStatus() {
    if (MqttService.isConnected) {
      _connectionStatus =
          'Conectado a MQTT (${MqttService.messagesReceived} msgs)';
      _statusColor = Colors.green;
    } else if (LoraWanService.isConnected) {
      _connectionStatus =
          'Conectado a LoRaWAN (${LoraWanService.messagesReceived} msgs)';
      _statusColor = Colors.green;
    } else {
      _connectionStatus = 'Desconectado';
      _statusColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración IoT'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _updateStatus();
              setState(() {});
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              color: _statusColor.withAlpha(30),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _statusColor == Colors.green
                          ? Icons.check_circle
                          : Icons.error,
                      color: _statusColor,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _connectionStatus,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Conexión MQTT',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Habilitar MQTT'),
              subtitle: Text(
                  'Conectar a broker para sensores físicos'),
              value: _useMqtt,
              onChanged: (v) => setState(() => _useMqtt = v),
            ),
            if (_useMqtt) ...[
              TextFormField(
                controller: _brokerCtrl,
                decoration: InputDecoration(
                  labelText: 'Broker',
                  hintText: 'broker.hivemq.com',
                  prefixIcon: Icon(Icons.dns),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _portCtrl,
                      decoration: InputDecoration(
                        labelText: 'Puerto',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _clientIdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Client ID',
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  labelText: 'Usuario (opcional)',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Contraseña (opcional)',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 12),
              CheckboxListTile(
                title: Text('Usar TLS/SSL'),
                value: _useTls,
                onChanged: (v) =>
                    setState(() => _useTls = v ?? false),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _topicsCtrl,
                decoration: InputDecoration(
                  labelText: 'Topics (uno por línea)',
                  prefixIcon: Icon(Icons.topic),
                ),
                maxLines: 4,
              ),
            ],
            Divider(height: 32),
            Text('Conexión LoRaWAN',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Habilitar LoRaWAN'),
              subtitle: Text(
                  'ChirpStack o The Things Network'),
              value: _useLoRa,
              onChanged: (v) => setState(() => _useLoRa = v),
            ),
            if (_useLoRa) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _loraServerCtrl,
                      decoration: InputDecoration(
                        labelText: 'Servidor',
                        prefixIcon: Icon(Icons.dns),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _loraPortCtrl,
                      decoration: InputDecoration(
                        labelText: 'Puerto',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _loraApiKeyCtrl,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  prefixIcon: Icon(Icons.key),
                ),
                obscureText: true,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _loraAppIdCtrl,
                decoration: InputDecoration(
                  labelText: 'Application ID',
                  prefixIcon: Icon(Icons.apps),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _loraDeviceEuiCtrl,
                decoration: InputDecoration(
                  labelText: 'Device EUI',
                  prefixIcon: Icon(Icons.memory),
                ),
              ),
            ],
            SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isConnecting ? null : _connect,
              icon: _isConnecting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.link),
              label: Text(_isConnecting
                  ? 'Conectando...'
                  : 'Conectar dispositivos'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            if (MqttService.isConnected || LoraWanService.isConnected) ...[
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _disconnect,
                icon: Icon(Icons.link_off, color: Colors.red),
                label: Text('Desconectar',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Conectando...';
      _statusColor = Colors.orange;
    });

    bool anyConnected = false;

    if (_useMqtt) {
      MqttService.updateConfig(MqttConfig(
        broker: _brokerCtrl.text,
        port: int.tryParse(_portCtrl.text) ?? 1883,
        clientId: _clientIdCtrl.text,
        username: _usernameCtrl.text.isNotEmpty ? _usernameCtrl.text : null,
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
        useTls: _useTls,
        topics: _topicsCtrl.text
            .split('\n')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
      ));

      final connected = await MqttService.connect();
      if (connected) {
        anyConnected = true;
        IoTService.setDataSource(DataSource.all);
        IoTService.startSimulation();
      }
    }

    if (_useLoRa) {
      LoraWanService.updateConfig(LoraWanConfig(
        server: _loraServerCtrl.text,
        port: int.tryParse(_loraPortCtrl.text) ?? 8080,
        apiKey:
            _loraApiKeyCtrl.text.isNotEmpty ? _loraApiKeyCtrl.text : null,
        applicationId: _loraAppIdCtrl.text.isNotEmpty
            ? _loraAppIdCtrl.text
            : null,
        deviceEui: _loraDeviceEuiCtrl.text.isNotEmpty
            ? _loraDeviceEuiCtrl.text
            : null,
      ));

      final connected = await LoraWanService.connect();
      if (connected) anyConnected = true;
    }

    setState(() {
      _isConnecting = false;
      if (anyConnected) {
        _connectionStatus =
            'Conectado exitosamente a hardware real';
        _statusColor = Colors.green;
      } else {
        _connectionStatus =
            'No se pudo conectar. Verifica la configuración.';
        _statusColor = Colors.red;
      }
    });
  }

  void _disconnect() {
    MqttService.disconnect();
    LoraWanService.stop();
    setState(() {
      _connectionStatus = 'Desconectado';
      _statusColor = Colors.red;
    });
  }
}
