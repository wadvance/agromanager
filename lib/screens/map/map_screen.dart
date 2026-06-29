import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../config/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final position = provider.currentPosition;

        return Scaffold(
          appBar: AppBar(title: Text('Mapa de la finca')),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 80,
                          color: theme.colorScheme.primary.withAlpha(100),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Mapa de la finca',
                          style: theme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Para visualizar el mapa, configura una API key de Google Maps o usa flutter_map con OpenStreetMap.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        if (position != null)
                          Card(
                            margin: EdgeInsets.symmetric(horizontal: 32),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Tu ubicación actual',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  SizedBox(height: 8),
                                  _infoRow(
                                      Icons.location_on,
                                      'Latitud',
                                      position.latitude.toStringAsFixed(6)),
                                  _infoRow(
                                      Icons.location_on,
                                      'Longitud',
                                      position.longitude.toStringAsFixed(6)),
                                ],
                              ),
                            ),
                          )
                        else
                          FilledButton.icon(
                            onPressed: () =>
                                provider.getCurrentLocation(),
                            icon: Icon(Icons.my_location),
                            label: Text('Obtener ubicación actual'),
                          ),
                        SizedBox(height: 16),
                        Text(
                          'Ubicación de referencia: Chiriquí, Panamá',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${AppConstants.chiriquiLat}, ${AppConstants.chiriquiLng}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
