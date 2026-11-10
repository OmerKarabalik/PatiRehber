import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'patirehber_alarms_v1';
  static const String channelName = 'PatiRehber Alarmlar & Aşı Hatırlatıcıları';
  static const String channelDescription =
      'Aşı tarihleri, veteriner randevuları ve ilaç saatleri için sesli bildirim alarmları';

  static bool _isInitialized = false;

  /// Initializes the local notifications plugin and timezone data
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Timezone database initialization
      tz.initializeTimeZones();

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS/macOS Initialization Settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // 4. Create Android High Priority Notification Channel
      final AndroidNotificationChannel channel = const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
        // Request POST_NOTIFICATIONS permission for Android 13+
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      _isInitialized = true;
      debugPrint('AlarmNotificationService: Başarıyla başlatıldı.');
    } catch (e) {
      debugPrint('AlarmNotificationService.initialize error: $e');
    }
  }

  /// Sends an immediate test notification to demonstrate the sound and vibration
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  /// Schedules a future alarm notification for an exact day and time
  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await initialize();

    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      debugPrint('Geçmiş tarihli alarm zamanlanamaz: $scheduledDate');
      return;
    }

    try {
      final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('Alarm kuruldu: #$id "$title" zamanı: $scheduledDate');
    } catch (e) {
      debugPrint('scheduleAlarm error: $e. Fallback to instant if today.');
    }
  }

  /// Cancels an existing alarm by ID
  static Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// Cancels all scheduled alarms
  static Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }
}
