import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../config/constants.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        final daily = provider.dailyForecast;

        return Scaffold(
          appBar: AppBar(
            title: Text('Clima'),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => provider.refreshWeather(),
              ),
            ],
          ),
          body: weather == null
              ? provider.isLoading
                  ? LoadingWidget(message: 'Obteniendo datos del clima...')
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'No se pudieron obtener datos del clima'),
                          SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => provider.refreshWeather(),
                            icon: Icon(Icons.refresh),
                            label: Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
              : RefreshIndicator(
                  onRefresh: () => provider.refreshWeather(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCurrentWeather(context, weather),
                        SizedBox(height: 24),
                        Text(
                          'Pronóstico semanal',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        if (daily.isEmpty)
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                  'Datos de pronóstico no disponibles'),
                            ),
                          )
                        else
                          ...daily.map((d) => _buildDailyCard(context, d)),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCurrentWeather(BuildContext context, dynamic weather) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  weather.iconUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.cloud, size: 64),
                ),
                SizedBox(width: 8),
                Text(
                  weather.temperatureString,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              weather.description.capitalize(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4),
            Text(
              weather.cityName.isNotEmpty
                  ? weather.cityName
                  : AppConstants.chiriquiName,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 4),
            Text(
              dateFormat.format(DateTime.now()),
              style: theme.textTheme.bodySmall,
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherDetail(Icons.water_drop, 'Humedad',
                    '${weather.humidity}%'),
                _weatherDetail(Icons.air, 'Viento',
                    '${weather.windSpeed} m/s'),
                _weatherDetail(Icons.compress, 'Presión',
                    '${weather.pressure.toInt()} hPa'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherDetail(
                    Icons.arrow_downward, 'Mín', weather.tempMin.toStringAsFixed(1) + '°'),
                _weatherDetail(Icons.arrow_upward, 'Máx',
                    weather.tempMax.toStringAsFixed(1) + '°'),
                _weatherDetail(
                    Icons.thermostat, 'Sensación',
                    weather.feelsLike.toStringAsFixed(1) + '°'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDailyCard(BuildContext context, dynamic day) {
    final dateFormat = DateFormat('EEEE d', 'es');
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                dateFormat.format(day.date),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${day.icon}.png',
              width: 32,
              height: 32,
              errorBuilder: (_, _, _) =>
                  Icon(Icons.cloud, size: 24),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                day.description.capitalize(),
                style: theme.textTheme.bodySmall,
              ),
            ),
            Text(
              '${day.tempMin.toStringAsFixed(0)}° / ${day.tempMax.toStringAsFixed(0)}°',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
