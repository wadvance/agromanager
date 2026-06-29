import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/app_provider.dart';
import '../services/firebase_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final role = provider.userRole;
        final roleName = RolePermissions.getRoleName(role);

        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.agriculture, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppConstants.chiriquiName,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor(role).withAlpha(100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleName,
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _drawerItem(context, Icons.dashboard, 'Dashboard', '/'),
                    _drawerItem(context, Icons.map, 'Mapa', '/map'),
                    _drawerItem(context, Icons.cloud, 'Clima', '/weather'),
                    _drawerItem(
                        context, Icons.analytics, 'Analíticas', '/analytics'),
                    _drawerItem(
                        context, Icons.sensors, 'Sensores IoT', '/sensors'),
                    Divider(),
                    _drawerItem(
                        context, Icons.grass, 'Cultivos', '/crops',
                        enabled: provider.canManageCrops),
                    _drawerItem(
                        context, Icons.pets, 'Ganado', '/livestock',
                        enabled: provider.canManageLivestock),
                    _drawerItem(
                        context, Icons.inventory, 'Inventario', '/inventory',
                        enabled: provider.canManageInventory),
                    _drawerItem(
                        context, Icons.account_balance, 'Finanzas', '/finances',
                        enabled: provider.canManageFinances),
                    _drawerItem(
                        context, Icons.checklist, 'Tareas', '/tasks'),
                    Divider(),
                    _drawerItem(
                        context, Icons.description, 'Reportes', '/reports',
                        enabled: provider.canExportReports),
                    if (provider.canManageUsers)
                      _drawerItem(
                          context, Icons.admin_panel_settings, 'Admin', '/admin'),
                  ],
                ),
              ),
              if (provider.isLoggedIn)
                Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Cerrar sesión'),
                    onTap: () {
                      FirebaseService.signOut();
                      provider.setLoggedIn(false);
                    },
                  ),
                ),
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: SwitchListTile(
                  title: Text('Modo oscuro'),
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  value: isDarkMode,
                  onChanged: onThemeToggle,
                ),
              ),
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('v${AppConstants.appVersion}'),
                  subtitle: Text('$roleName | AgroManager'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label,
      String route,
      {bool enabled = true}) {
    final isSelected = currentRoute == route;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : enabled
                ? null
                : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? theme.colorScheme.primary
              : enabled
                  ? null
                  : Colors.grey,
        ),
      ),
      selected: isSelected,
      enabled: enabled,
      onTap: enabled
          ? () {
              Navigator.pop(context);
              if (currentRoute != route) {
                Navigator.pushReplacementNamed(context, route);
              }
            }
          : null,
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return Colors.red;
      case AppConstants.roleAdmin:
        return Colors.orange;
      case AppConstants.roleCapataz:
        return Colors.blue;
      case AppConstants.roleUsuario:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
