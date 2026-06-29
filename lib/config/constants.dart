class AppConstants {
  AppConstants._();

  static const String appName = 'AgroManager';
  static const String appVersion = '1.0.0';

  static const double chiriquiLat = 8.4167;
  static const double chiriquiLng = -82.3333;
  static const String chiriquiName = 'Chiriquí, Panamá';

  static const String weatherApiKey = '72c074fd029ea709c8556e780ca50415';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

  static const String dbName = 'agromanager.db';
  static const int dbVersion = 2;

  static const String mqttBroker = 'broker.hivemq.com';
  static const int mqttPort = 1883;

  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleCapataz = 'capataz';
  static const String roleUsuario = 'usuario';
}

class RoleNames {
  RoleNames._();
  static const String superAdmin = 'Super Admin';
  static const String admin = 'Administrador';
  static const String capataz = 'Capataz';
  static const String usuario = 'Usuario';
}

class RolePermissions {
  RolePermissions._();

  static const List<String> allRoles = [
    AppConstants.roleSuperAdmin,
    AppConstants.roleAdmin,
    AppConstants.roleCapataz,
    AppConstants.roleUsuario,
  ];

  static bool canManageUsers(String role) =>
      role == AppConstants.roleSuperAdmin || role == AppConstants.roleAdmin;

  static bool canManageRoles(String role) =>
      role == AppConstants.roleSuperAdmin;

  static bool canManageCrops(String role) =>
      role != AppConstants.roleUsuario;

  static bool canManageLivestock(String role) =>
      role != AppConstants.roleUsuario;

  static bool canManageInventory(String role) =>
      role != AppConstants.roleUsuario;

  static bool canManageFinances(String role) =>
      role == AppConstants.roleSuperAdmin || role == AppConstants.roleAdmin;

  static bool canViewAnalytics(String role) => true;

  static bool canViewSensors(String role) => true;

  static bool canManageSensors(String role) =>
      role == AppConstants.roleSuperAdmin || role == AppConstants.roleAdmin;

  static bool canExportReports(String role) =>
      role != AppConstants.roleUsuario;

  static bool canSyncCloud(String role) =>
      role == AppConstants.roleSuperAdmin || role == AppConstants.roleAdmin;

  static String getRoleName(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return RoleNames.superAdmin;
      case AppConstants.roleAdmin:
        return RoleNames.admin;
      case AppConstants.roleCapataz:
        return RoleNames.capataz;
      case AppConstants.roleUsuario:
        return RoleNames.usuario;
      default:
        return 'Desconocido';
    }
  }
}
