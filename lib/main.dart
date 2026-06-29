import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.initialize();
  } catch (_) {}

  await NotificationService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const AgroManagerApp(),
    ),
  );
}
