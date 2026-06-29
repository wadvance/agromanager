import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/constants.dart';
import '../models/crop.dart';
import '../models/livestock.dart';
import '../models/inventory_item.dart';
import '../models/finance_record.dart';
import '../models/farm_task.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        variety TEXT,
        plantingDate TEXT NOT NULL,
        harvestDate TEXT,
        area REAL NOT NULL,
        status TEXT DEFAULT 'growing',
        notes TEXT,
        quantity REAL DEFAULT 0,
        cost REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE livestock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        breed TEXT,
        birthDate TEXT NOT NULL,
        weight REAL DEFAULT 0,
        gender TEXT,
        healthStatus TEXT DEFAULT 'healthy',
        notes TEXT,
        purchaseCost REAL DEFAULT 0,
        salePrice REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT DEFAULT 'general',
        quantity INTEGER NOT NULL DEFAULT 0,
        unit TEXT DEFAULT 'unidad',
        unitPrice REAL DEFAULT 0,
        minStockLevel INTEGER DEFAULT 0,
        supplier TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        category TEXT DEFAULT 'general',
        date TEXT NOT NULL,
        paymentMethod TEXT DEFAULT 'efectivo',
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER DEFAULT 1,
        status INTEGER DEFAULT 0,
        createdDate TEXT NOT NULL,
        dueDate TEXT,
        completedDate TEXT,
        assignedTo TEXT,
        category TEXT DEFAULT 'general',
        locationLat REAL,
        locationLng REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE sensors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        location TEXT,
        batteryLevel REAL,
        isOnline INTEGER DEFAULT 1,
        timestamp TEXT NOT NULL,
        minThreshold REAL,
        maxThreshold REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE sensor_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sensorId INTEGER NOT NULL,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (sensorId) REFERENCES sensors(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sensors (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          value REAL NOT NULL,
          unit TEXT NOT NULL,
          location TEXT,
          batteryLevel REAL,
          isOnline INTEGER DEFAULT 1,
          timestamp TEXT NOT NULL,
          minThreshold REAL,
          maxThreshold REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sensor_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sensorId INTEGER NOT NULL,
          value REAL NOT NULL,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (sensorId) REFERENCES sensors(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  static Future<int> insertCrop(Crop crop) async {
    final db = await database;
    final map = crop.toMap();
    map.remove('id');
    return await db.insert('crops', map);
  }

  static Future<List<Crop>> getCrops() async {
    final db = await database;
    final maps = await db.query('crops', orderBy: 'plantingDate DESC');
    return maps.map((m) => Crop.fromMap(m)).toList();
  }

  static Future<Crop?> getCrop(int id) async {
    final db = await database;
    final maps = await db.query('crops', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Crop.fromMap(maps.first);
  }

  static Future<int> updateCrop(Crop crop) async {
    final db = await database;
    return await db.update('crops', crop.toMap(),
        where: 'id = ?', whereArgs: [crop.id]);
  }

  static Future<int> deleteCrop(int id) async {
    final db = await database;
    return await db.delete('crops', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertLivestock(Livestock animal) async {
    final db = await database;
    final map = animal.toMap();
    map.remove('id');
    return await db.insert('livestock', map);
  }

  static Future<List<Livestock>> getLivestock() async {
    final db = await database;
    final maps = await db.query('livestock', orderBy: 'birthDate DESC');
    return maps.map((m) => Livestock.fromMap(m)).toList();
  }

  static Future<Livestock?> getLivestockById(int id) async {
    final db = await database;
    final maps =
        await db.query('livestock', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Livestock.fromMap(maps.first);
  }

  static Future<int> updateLivestock(Livestock animal) async {
    final db = await database;
    return await db.update('livestock', animal.toMap(),
        where: 'id = ?', whereArgs: [animal.id]);
  }

  static Future<int> deleteLivestock(int id) async {
    final db = await database;
    return await db.delete('livestock', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    final map = item.toMap();
    map.remove('id');
    return await db.insert('inventory', map);
  }

  static Future<List<InventoryItem>> getInventoryItems() async {
    final db = await database;
    final maps = await db.query('inventory', orderBy: 'name ASC');
    return maps.map((m) => InventoryItem.fromMap(m)).toList();
  }

  static Future<int> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.update('inventory', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<int> deleteInventoryItem(int id) async {
    final db = await database;
    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertFinanceRecord(FinanceRecord record) async {
    final db = await database;
    final map = record.toMap();
    map.remove('id');
    return await db.insert('finances', map);
  }

  static Future<List<FinanceRecord>> getFinanceRecords() async {
    final db = await database;
    final maps = await db.query('finances', orderBy: 'date DESC');
    return maps.map((m) => FinanceRecord.fromMap(m)).toList();
  }

  static Future<List<FinanceRecord>> getFinanceRecordsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'finances',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((m) => FinanceRecord.fromMap(m)).toList();
  }

  static Future<int> updateFinanceRecord(FinanceRecord record) async {
    final db = await database;
    return await db.update('finances', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  static Future<int> deleteFinanceRecord(int id) async {
    final db = await database;
    return await db.delete('finances', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, double>> getFinanceSummary() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN type = 0 THEN amount ELSE 0 END) as totalIncome,
        SUM(CASE WHEN type = 1 THEN amount ELSE 0 END) as totalExpense
      FROM finances
    ''');
    final row = result.first;
    return {
      'totalIncome': (row['totalIncome'] as num?)?.toDouble() ?? 0,
      'totalExpense': (row['totalExpense'] as num?)?.toDouble() ?? 0,
    };
  }

  static Future<int> insertTask(FarmTask task) async {
    final db = await database;
    final map = task.toMap();
    map.remove('id');
    return await db.insert('tasks', map);
  }

  static Future<List<FarmTask>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdDate DESC');
    return maps.map((m) => FarmTask.fromMap(m)).toList();
  }

  static Future<List<FarmTask>> getPendingTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'status < 2',
      orderBy: 'priority DESC, dueDate ASC',
    );
    return maps.map((m) => FarmTask.fromMap(m)).toList();
  }

  static Future<int> updateTask(FarmTask task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final db = await database;
    final cropCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM crops'))
            ?.toDouble() ??
        0;
    final livestockCount =
        Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM livestock'))
            ?.toDouble() ??
        0;
    final pendingTasks =
        Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE status < 2'))
            ?.toDouble() ??
        0;
    final lowStock = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM inventory WHERE quantity <= minStockLevel'))
        ?.toDouble() ??
        0;
    final totalValue = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT SUM(quantity * unitPrice) FROM inventory'))
        ?.toDouble() ??
        0;

    return {
      'totalCrops': cropCount,
      'totalLivestock': livestockCount,
      'pendingTasks': pendingTasks,
      'lowStockItems': lowStock,
      'inventoryValue': totalValue,
    };
  }
}
