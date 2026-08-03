import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const String _prefKey = 'notifications_enabled';

  Future<void> init() async {
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> toggleNotifications(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enable);

    if (kIsWeb) return;

    if (enable) {
      await _scheduleDailyReminder();
    } else {
      await _cancelAllNotifications();
    }
  }

  Future<void> _cancelAllNotifications() async {
    if (kIsWeb) return;
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleDailyReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Lembretes Diários',
      channelDescription: 'Canal para lembrar de registrar os gastos do dia',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      0, 
      'Como está seu bolso hoje?', 
      'Não se esqueça de registrar as suas transações de hoje no FlowFinance! 💸', 
      RepeatInterval.daily, 
      platformDetails,
      androidAllowWhileIdle: true,
    );
  }
}