import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import '../weather/weather_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadAll();
      provider.refreshWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.dashboardSummary == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Dashboard')),
            body: LoadingWidget(message: 'Cargando datos de la finca...'),
          );
        }

        final summary = provider.dashboardSummary;
        final weather = provider.weather;

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadAll();
            await provider.refreshWeather();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Dashboard'),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    provider.loadAll();
                    provider.refreshWeather();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (weather != null) _buildWeatherCard(context, weather),
                  SizedBox(height: 16),
                  Text(
                    'Resumen de la finca',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      StatCard(
                        title: 'Cultivos',
                        value: '${(summary?['totalCrops'] ?? 0).toInt()}',
                        icon: Icons.grass,
                        color: Colors.green,
                        onTap: () =>
                            Navigator.pushNamed(context, '/crops'),
                      ),
                      StatCard(
                        title: 'Ganado',
                        value: '${(summary?['totalLivestock'] ?? 0).toInt()}',
                        icon: Icons.pets,
                        color: Colors.brown,
                        onTap: () =>
                            Navigator.pushNamed(context, '/livestock'),
                      ),
                      StatCard(
                        title: 'Tareas pendientes',
                        value: '${(summary?['pendingTasks'] ?? 0).toInt()}',
                        icon: Icons.checklist,
                        color: Colors.orange,
                        onTap: () =>
                            Navigator.pushNamed(context, '/tasks'),
                      ),
                      StatCard(
                        title: 'Stock bajo',
                        value: '${(summary?['lowStockItems'] ?? 0).toInt()}',
                        icon: Icons.inventory,
                        color: Colors.red,
                        onTap: () =>
                            Navigator.pushNamed(context, '/inventory'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valor del inventario',
                            style: theme.textTheme.titleSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            currencyFormat.format(summary?['inventoryValue'] ?? 0),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard(BuildContext context, dynamic weather) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d MMMM', 'es');

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WeatherScreen()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chiriquí, Panamá',
                    style: theme.textTheme.titleSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    weather.temperatureString,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.description.capitalize(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Image.network(
                    weather.iconUrl,
                    width: 64,
                    height: 64,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.cloud, size: 48),
                  ),
                  Text(
                    dateFormat.format(DateTime.now()),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
