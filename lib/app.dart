import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'services/firebase_service.dart';
import 'widgets/app_drawer.dart';
import 'dart:io' show Platform;
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/web_dashboard_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/crops/crops_screen.dart';
import 'screens/livestock/livestock_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/finances/finances_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/reports/analytics_screen.dart';
import 'screens/sensors/sensors_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/auth/login_screen.dart';

class AgroManagerApp extends StatefulWidget {
  const AgroManagerApp({super.key});

  @override
  State<AgroManagerApp> createState() => _AgroManagerAppState();
}

class _AgroManagerAppState extends State<AgroManagerApp> {
  bool _isDarkMode = false;
  String _currentRoute = '/';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadAll();
      if (FirebaseService.isSignedIn) {
        provider.setLoggedIn(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoggedIn) {
          return MaterialApp(
            title: 'AgroManager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: LoginScreen(),
          );
        }

        return MaterialApp(
          title: 'AgroManager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            _currentRoute = settings.name ?? '/';
            return MaterialPageRoute(
              builder: (_) => _buildScreen(settings.name ?? '/'),
              settings: settings,
            );
          },
        );
      },
    );
  }

  bool get _isWeb {
    try {
      return Platform.operatingSystem == 'web';
    } catch (_) {
      return true;
    }
  }

  Widget _buildScreen(String route) {
    final Widget screen;
    switch (route) {
      case '/':
        screen = _isWeb
            ? const WebDashboardScreen()
            : const DashboardScreen();
        break;
      case '/map':
        screen = const MapScreen();
        break;
      case '/weather':
        screen = const WeatherScreen();
        break;
      case '/crops':
        screen = const CropsScreen();
        break;
      case '/livestock':
        screen = const LivestockScreen();
        break;
      case '/inventory':
        screen = const InventoryScreen();
        break;
      case '/finances':
        screen = const FinancesScreen();
        break;
      case '/tasks':
        screen = const TasksScreen();
        break;
      case '/reports':
        screen = const ReportsScreen();
        break;
      case '/analytics':
        screen = const AnalyticsScreen();
        break;
      case '/sensors':
        screen = const SensorsScreen();
        break;
      case '/admin':
        screen = const AdminScreen();
        break;
      default:
        screen = const DashboardScreen();
    }

    return Builder(
      builder: (context) => Scaffold(
        drawer: AppDrawer(
          currentRoute: _currentRoute,
          isDarkMode: _isDarkMode,
          onThemeToggle: (v) => setState(() => _isDarkMode = v),
        ),
        body: screen,
      ),
    );
  }
}
