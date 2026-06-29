import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/crop.dart';
import '../models/livestock.dart';
import '../models/inventory_item.dart';
import '../models/finance_record.dart';
import '../models/farm_task.dart';
import '../models/weather_data.dart';
import '../services/database_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../services/role_service.dart';
import '../config/constants.dart';

class AppProvider extends ChangeNotifier {
  List<Crop> _crops = [];
  List<Livestock> _livestock = [];
  List<InventoryItem> _inventory = [];
  List<FinanceRecord> _finances = [];
  List<FarmTask> _tasks = [];
  WeatherData? _weather;
  List<DailyForecast> _dailyForecast = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  bool _isLoggedIn = false;
  bool _isSyncing = false;
  String? _syncMessage;
  String _userRole = AppConstants.roleUsuario;
  final bool _isOnline = true;

  List<Crop> get crops => _crops;
  List<Livestock> get livestock => _livestock;
  List<InventoryItem> get inventory => _inventory;
  List<FinanceRecord> get finances => _finances;
  List<FarmTask> get tasks => _tasks;
  List<FarmTask> get pendingTasks =>
      _tasks.where((t) => t.status.index < 2).toList();
  WeatherData? get weather => _weather;
  List<DailyForecast> get dailyForecast => _dailyForecast;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSyncing => _isSyncing;
  String? get syncMessage => _syncMessage;
  String get userRole => _userRole;
  bool get isOnline => _isOnline;
  bool get canManageUsers => RolePermissions.canManageUsers(_userRole);
  bool get canManageRoles => RolePermissions.canManageRoles(_userRole);
  bool get canManageCrops => RolePermissions.canManageCrops(_userRole);
  bool get canManageLivestock => RolePermissions.canManageLivestock(_userRole);
  bool get canManageInventory => RolePermissions.canManageInventory(_userRole);
  bool get canManageFinances => RolePermissions.canManageFinances(_userRole);
  bool get canExportReports => RolePermissions.canExportReports(_userRole);
  bool get canSyncCloud => RolePermissions.canSyncCloud(_userRole);
  bool get canManageSensors => RolePermissions.canManageSensors(_userRole);

  Map<String, dynamic>? _dashboardSummary;
  Map<String, dynamic>? get dashboardSummary => _dashboardSummary;

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    if (value) {
      _loadUserRole();
    }
    notifyListeners();
  }

  void skipLogin() {
    _isLoggedIn = true;
    _userRole = AppConstants.roleUsuario;
    notifyListeners();
    loadAll();
  }

  Future<void> _loadUserRole() async {
    try {
      _userRole = await RoleService.getCurrentUserRole();
    } catch (_) {
      _userRole = AppConstants.roleUsuario;
    }
    notifyListeners();
  }

  Future<void> updateUserRole(String uid, String role) async {
    await RoleService.setUserRole(uid, role);
    if (uid == FirebaseService.currentUser?.uid) {
      _userRole = role;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardSummary = await DatabaseService.getDashboardSummary();
      _crops = await DatabaseService.getCrops();
      _livestock = await DatabaseService.getLivestock();
      _inventory = await DatabaseService.getInventoryItems();
      _finances = await DatabaseService.getFinanceRecords();
      _tasks = await DatabaseService.getTasks();
    } catch (e) {
      _error = 'Error al cargar datos: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    try {
      _weather = await WeatherService.getCurrentWeather();
      final hourly = await WeatherService.getHourlyForecast();
      _dailyForecast = WeatherService.aggregateDailyForecast(hourly);
      notifyListeners();
      if (_weather!.isRaining) {
        NotificationService.notifyWeatherAlert(
          'Se espera lluvia en Chiriquí: ${_weather!.description}',
        );
      }
    } catch (e) {
      _error = 'Error al obtener clima: $e';
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await LocationService.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener ubicación: $e';
      notifyListeners();
    }
  }

  Future<void> addCrop(Crop crop) async {
    await DatabaseService.insertCrop(crop);
    _crops = await DatabaseService.getCrops();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> updateCrop(Crop crop) async {
    await DatabaseService.updateCrop(crop);
    _crops = await DatabaseService.getCrops();
    notifyListeners();
  }

  Future<void> deleteCrop(int id) async {
    await DatabaseService.deleteCrop(id);
    _crops = await DatabaseService.getCrops();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> addLivestock(Livestock animal) async {
    await DatabaseService.insertLivestock(animal);
    _livestock = await DatabaseService.getLivestock();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> updateLivestock(Livestock animal) async {
    await DatabaseService.updateLivestock(animal);
    _livestock = await DatabaseService.getLivestock();
    notifyListeners();
  }

  Future<void> deleteLivestock(int id) async {
    await DatabaseService.deleteLivestock(id);
    _livestock = await DatabaseService.getLivestock();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    await DatabaseService.insertInventoryItem(item);
    _inventory = await DatabaseService.getInventoryItems();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await DatabaseService.updateInventoryItem(item);
    _inventory = await DatabaseService.getInventoryItems();
    notifyListeners();
  }

  Future<void> deleteInventoryItem(int id) async {
    await DatabaseService.deleteInventoryItem(id);
    _inventory = await DatabaseService.getInventoryItems();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> addFinanceRecord(FinanceRecord record) async {
    await DatabaseService.insertFinanceRecord(record);
    _finances = await DatabaseService.getFinanceRecords();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> updateFinanceRecord(FinanceRecord record) async {
    await DatabaseService.updateFinanceRecord(record);
    _finances = await DatabaseService.getFinanceRecords();
    notifyListeners();
  }

  Future<void> deleteFinanceRecord(int id) async {
    await DatabaseService.deleteFinanceRecord(id);
    _finances = await DatabaseService.getFinanceRecords();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<void> addTask(FarmTask task) async {
    await DatabaseService.insertTask(task);
    _tasks = await DatabaseService.getTasks();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
    NotificationService.scheduleTaskReminder(task);
    NotificationService.checkAndNotifyLowStock(_inventory);
  }

  Future<void> updateTask(FarmTask task) async {
    await DatabaseService.updateTask(task);
    _tasks = await DatabaseService.getTasks();
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseService.deleteTask(id);
    _tasks = await DatabaseService.getTasks();
    _dashboardSummary = await DatabaseService.getDashboardSummary();
    notifyListeners();
  }

  Future<Map<String, double>> getFinanceSummary() async {
    return await DatabaseService.getFinanceSummary();
  }

  Future<void> syncToCloud() async {
    if (!_isLoggedIn || _isSyncing) return;
    _isSyncing = true;
    _syncMessage = 'Sincronizando...';
    notifyListeners();

    try {
      await FirebaseService.syncAll(
        crops: _crops,
        livestock: _livestock,
        inventory: _inventory,
        finances: _finances,
        tasks: _tasks,
      );
      _syncMessage = 'Sincronización completa';
    } catch (e) {
      _syncMessage = 'Error de sincronización: $e';
    }

    _isSyncing = false;
    notifyListeners();
    await Future.delayed(Duration(seconds: 3));
    _syncMessage = null;
    notifyListeners();
  }

  Future<void> syncFromCloud() async {
    if (!_isLoggedIn) return;
    _isSyncing = true;
    _syncMessage = 'Descargando...';
    notifyListeners();

    try {
      _crops = await FirebaseService.getCrops();
      _livestock = await FirebaseService.getLivestock();
      _inventory = await FirebaseService.getInventory();
      _finances = await FirebaseService.getFinances();
      _tasks = await FirebaseService.getTasks();

      for (final c in _crops) {
        if (c.id == null) continue;
        final existing = await DatabaseService.getCrop(c.id!);
        if (existing != null) {
          await DatabaseService.updateCrop(c);
        } else {
          await DatabaseService.insertCrop(c);
        }
      }
      await loadAll();
      _syncMessage = 'Datos descargados';
    } catch (e) {
      _syncMessage = 'Error al descargar: $e';
    }

    _isSyncing = false;
    notifyListeners();
    await Future.delayed(Duration(seconds: 3));
    _syncMessage = null;
    notifyListeners();
  }

  Future<void> exportCropReport() async {
    final file = await ExportService.generateCropReportPdf(_crops);
    await ExportService.shareFile(file);
  }

  Future<void> exportLivestockReport() async {
    final file =
        await ExportService.generateLivestockReportPdf(_livestock);
    await ExportService.shareFile(file);
  }

  Future<void> exportInventoryReport() async {
    final file =
        await ExportService.generateInventoryReportPdf(_inventory);
    await ExportService.shareFile(file);
  }

  Future<void> exportFinanceReport() async {
    final file =
        await ExportService.generateFinanceReportPdf(_finances);
    await ExportService.shareFile(file);
  }

  Future<void> exportTaskReport() async {
    final file = await ExportService.generateTaskReportPdf(_tasks);
    await ExportService.shareFile(file);
  }

  Future<void> exportFullReport() async {
    final file = await ExportService.generateFullReportPdf(
      crops: _crops,
      livestock: _livestock,
      inventory: _inventory,
      finances: _finances,
      tasks: _tasks,
    );
    await ExportService.shareFile(file);
  }

  Future<void> exportCropCsv() async {
    final file = await ExportService.generateCropCsv(_crops);
    await ExportService.shareFile(file);
  }

  Future<void> exportFinanceCsv() async {
    final file = await ExportService.generateFinanceCsv(_finances);
    await ExportService.shareFile(file);
  }

  Future<void> exportInventoryCsv() async {
    final file = await ExportService.generateInventoryCsv(_inventory);
    await ExportService.shareFile(file);
  }
}
