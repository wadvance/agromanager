import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import '../../models/farm_task.dart';
import '../../services/firebase_service.dart';
import '../../services/iot_service.dart';
import '../weather/weather_screen.dart';


String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

class WebDashboardScreen extends StatelessWidget {
  const WebDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.dashboardSummary == null) {
          return LoadingWidget(message: 'Cargando...');
        }

        final summary = provider.dashboardSummary;
        final weather = provider.weather;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.agriculture, size: 28),
                SizedBox(width: 12),
                Text('AgroManager'),
                if (isLargeScreen) ...[
                  SizedBox(width: 32),
                  _navChip(context, 'Dashboard', '/', Icons.dashboard),
                  _navChip(context, 'Cultivos', '/crops', Icons.grass),
                  _navChip(context, 'Ganado', '/livestock', Icons.pets),
                  _navChip(context, 'IoT', '/sensors', Icons.sensors),
                  _navChip(
                      context, 'Reportes', '/reports', Icons.description),
                ],
              ],
            ),
            actions: [
              if (provider.isLoggedIn)
                PopupMenuButton<String>(
                  icon: Icon(Icons.account_circle),
                  onSelected: (v) {
                    if (v == 'logout') {
                      FirebaseService.signOut();
                      provider.setLoggedIn(false);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Text(provider.userRole),
                      enabled: false,
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Cerrar sesión'),
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  provider.loadAll();
                  provider.refreshWeather();
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildLargeLayout(
                    context, provider, summary, weather, currencyFormat);
              } else if (constraints.maxWidth > 600) {
                return _buildMediumLayout(
                    context, provider, summary, weather, currencyFormat);
              } else {
                return _buildSmallLayout(
                    context, provider, summary, weather, currencyFormat);
              }
            },
          ),
        );
      },
    );
  }

  Widget _navChip(BuildContext context, String label, String route, IconData icon) {
    final isSelected = ModalRoute.of(context)?.settings.name == route;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: () => Navigator.pushReplacementNamed(context, route),
        icon: Icon(icon, size: 18),
        label: Text(label, style: TextStyle(fontSize: 13)),
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.white70,
          backgroundColor: isSelected ? Colors.white.withAlpha(30) : null,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildLargeLayout(BuildContext context, AppProvider provider,
      Map? summary, dynamic weather, NumberFormat currencyFormat) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Panel de control',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Bienvenido a AgroManager — ${provider.userRole}',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildStatsGrid(
                  context, summary, currencyFormat)),
              SizedBox(width: 24),
              Expanded(
                  flex: 1,
                  child: _buildWeatherPanel(context, weather)),
            ],
          ),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: _buildRecentFinances(context, provider)),
              SizedBox(width: 24),
              Expanded(
                  flex: 1,
                  child: _buildPendingTasks(context, provider)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediumLayout(BuildContext context, AppProvider provider,
      Map? summary, dynamic weather, NumberFormat currencyFormat) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Panel de control',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          _buildStatsGrid(context, summary, currencyFormat),
          SizedBox(height: 20),
          if (weather != null) _buildWeatherPanel(context, weather),
          SizedBox(height: 20),
          _buildRecentFinances(context, provider),
          SizedBox(height: 20),
          _buildPendingTasks(context, provider),
        ],
      ),
    );
  }

  Widget _buildSmallLayout(BuildContext context, AppProvider provider,
      Map? summary, dynamic weather, NumberFormat currencyFormat) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Panel de control',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          if (weather != null) _buildWeatherCard(context, weather),
          SizedBox(height: 16),
          _buildStatsGrid(context, summary, currencyFormat),
          SizedBox(height: 16),
          _buildRecentFinances(context, provider),
          SizedBox(height: 16),
          _buildPendingTasks(context, provider),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, Map? summary, NumberFormat currencyFormat) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Cultivos',
          value: '${(summary?['totalCrops'] ?? 0).toInt()}',
          icon: Icons.grass,
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, '/crops'),
        ),
        StatCard(
          title: 'Ganado',
          value: '${(summary?['totalLivestock'] ?? 0).toInt()}',
          icon: Icons.pets,
          color: Colors.brown,
          onTap: () => Navigator.pushNamed(context, '/livestock'),
        ),
        StatCard(
          title: 'Tareas pendientes',
          value: '${(summary?['pendingTasks'] ?? 0).toInt()}',
          icon: Icons.checklist,
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/tasks'),
        ),
        StatCard(
          title: 'Stock bajo',
          value: '${(summary?['lowStockItems'] ?? 0).toInt()}',
          icon: Icons.inventory,
          color: Colors.red,
          onTap: () => Navigator.pushNamed(context, '/inventory'),
        ),
        StatCard(
          title: 'Valor inventario',
          value: currencyFormat.format(summary?['inventoryValue'] ?? 0),
          icon: Icons.attach_money,
          color: Colors.teal,
        ),
        StatCard(
          title: 'Sensores IoT',
          value: '${IoTService.sensors.length}',
          icon: Icons.sensors,
          color: Colors.indigo,
          onTap: () => Navigator.pushNamed(context, '/sensors'),
        ),
      ],
    );
  }

  Widget _buildWeatherPanel(BuildContext context, dynamic weather) {
    final theme = Theme.of(context);
    if (weather == null) return SizedBox.shrink();

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => WeatherScreen())),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, color: theme.colorScheme.primary),
                  SizedBox(width: 8),
                  Text('Clima ahora',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(weather.iconUrl,
                      width: 64,
                      height: 64,
                      errorBuilder: (_, _, _) =>
                          Icon(Icons.cloud, size: 48)),
                  SizedBox(width: 8),
                  Text(weather.temperatureString,
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_capitalize(weather.description),
                          style: theme.textTheme.bodyMedium),
                      Text('Chiriquí, Panamá',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _detailCol(Icons.water_drop, '${weather.humidity}%', 'Humedad'),
                  _detailCol(Icons.air, '${weather.windSpeed} m/s', 'Viento'),
                  _detailCol(Icons.compress, '${weather.pressure.toInt()} hPa', 'Presión'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, dynamic weather) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => WeatherScreen())),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Image.network(weather.iconUrl,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.cloud, size: 36)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weather.temperatureString,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(_capitalize(weather.description),
                      style: theme.textTheme.bodyMedium),
                ],
              ),
              Spacer(),
              Text('Chiriquí', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailCol(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentFinances(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final recent = provider.finances.take(5).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Últimas transacciones',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/finances'),
                  child: Text('Ver todo'),
                ),
              ],
            ),
            if (recent.isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sin transacciones',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ...recent.map((r) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          r.type.index == 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 18,
                          color: r.type.index == 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(r.description,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          currencyFormat.format(r.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: r.type.index == 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasks(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    final pending = provider.pendingTasks.take(5).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tareas pendientes',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/tasks'),
                  child: Text('Ver todo'),
                ),
              ],
            ),
            if (pending.isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sin tareas pendientes',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ...pending.map((t) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.circle,
                      size: 10,
                      color: t.priority == TaskPriority.urgent
                          ? Colors.red
                          : t.priority == TaskPriority.high
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    title: Text(t.title,
                        style: TextStyle(fontSize: 14)),
                    subtitle: t.dueDate != null
                        ? Text(
                            DateFormat('dd/MM').format(t.dueDate!),
                            style: TextStyle(fontSize: 12))
                        : null,
                  )),
          ],
        ),
      ),
    );
  }
}
