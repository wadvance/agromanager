import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/farm_task.dart';
import '../models/inventory_item.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'agromanager_channel',
      'AgroManager',
      channelDescription: 'Notificaciones de la finca',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleTaskReminder(FarmTask task) async {
    if (task.dueDate == null) return;

    final now = DateTime.now();
    final dueDate = task.dueDate!;

    if (dueDate.isBefore(now)) return;

    final reminderTime = dueDate.subtract(const Duration(hours: 2));
    if (reminderTime.isAfter(now)) {
      final delay = reminderTime.difference(now);
      await Future.delayed(delay, () {
        showNotification(
          id: task.id ?? 0,
          title: 'Tarea próxima: ${task.title}',
          body: 'Vence en menos de 2 horas',
        );
      });
    }
  }

  static Future<void> notifyLowStock(InventoryItem item) async {
    await showNotification(
      id: 1000 + (item.id ?? 0),
      title: 'Stock bajo: ${item.name}',
      body: 'Quedan ${item.quantity} ${item.unit} (mín: ${item.minStockLevel})',
    );
  }

  static Future<void> notifyWeatherAlert(String message) async {
    await showNotification(
      id: 9999,
      title: 'Alerta del clima',
      body: message,
    );
  }

  static Future<void> checkAndNotifyLowStock(
      List<InventoryItem> items) async {
    for (final item in items) {
      if (item.isLowStock) {
        await notifyLowStock(item);
      }
    }
  }
}
