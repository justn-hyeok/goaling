import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleGoalReminder({
    required String goalId,
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'goal_reminders',
      '목표 리마인더',
      channelDescription: '목표 마감일 알림',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 마감 하루 전 알림
    final reminderDate = deadline.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        int.parse(goalId.split('-')[0]), // 알림 ID로 goalId의 첫 부분 사용
        '목표 마감 임박',
        '$title의 마감일이 내일입니다.',
        tz.TZDateTime.from(reminderDate, tz.local),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // 매주 진행상황 체크 알림
    final weeklyCheckDate = DateTime.now().add(const Duration(days: 7));
    if (weeklyCheckDate.isBefore(deadline)) {
      await _notifications.zonedSchedule(
        int.parse(goalId.split('-')[0]) + 1,
        '주간 목표 체크인',
        '$title의 진행상황을 체크해보세요.',
        tz.TZDateTime.from(weeklyCheckDate, tz.local),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelGoalReminders(String goalId) async {
    await _notifications.cancel(int.parse(goalId.split('-')[0]));
    await _notifications.cancel(int.parse(goalId.split('-')[0]) + 1);
  }

  Future<void> showGoalCompletionNotification({
    required String title,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'goal_completion',
      '목표 달성',
      channelDescription: '목표 달성 축하 알림',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '목표 달성 축하!',
      '$title 목표를 달성했습니다! 🎉',
      details,
    );
  }
}
