import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifyService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'masjid_silencer',
    'Masjid Silencer',
    description: 'Shows when auto-silence is active',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );

  static Future<void> init() async {
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> show() => _plugin.show(
        10,                                // id
        'Masjid Silencer',
        'Auto-silencing near masjids is ON',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            ongoing: true,
            importance: Importance.low,
            priority: Priority.low,
          ),
        ),
      );

  static Future<void> cancel() => _plugin.cancel(10);
}
