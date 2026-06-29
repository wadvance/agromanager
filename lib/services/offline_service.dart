import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static const _queueKey = 'sync_queue';
  static List<Map<String, dynamic>> _queue = [];

  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((c) =>
        c == ConnectivityResult.wifi ||
        c == ConnectivityResult.mobile ||
        c == ConnectivityResult.ethernet);
  }

  static Future<void> enqueue(String operation, String collection,
      Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    _queue.add({
      'operation': operation,
      'collection': collection,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_queueKey, json.encode(_queue));
  }

  static Future<List<Map<String, dynamic>>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_queueKey);
    if (stored != null) {
      _queue = List<Map<String, dynamic>>.from(json.decode(stored));
    }
    return _queue;
  }

  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    _queue.clear();
    await prefs.remove(_queueKey);
  }

  static Future<void> processQueue() async {
    if (!await isOnline()) return;

    final queue = await getQueue();
    if (queue.isEmpty) return;

    for (final item in queue) {
      try {
        switch (item['collection']) {
          case 'crops':
          case 'livestock':
          case 'inventory':
          case 'finances':
          case 'tasks':
            break;
        }
      } catch (_) {}
    }

    await clearQueue();
  }
}
