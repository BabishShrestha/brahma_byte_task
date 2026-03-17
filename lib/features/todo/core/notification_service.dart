import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

class NotificationService {
  static final NotificationService instance = NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapStreamController =
      StreamController<String>.broadcast();

  bool _isInitialized = false;
  Future<void>? _initFuture;
  String? _launchPayload;

  Stream<String> get notificationTapStream => _tapStreamController.stream;

  NotificationService._init();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_initFuture != null) {
      return _initFuture;
    }

    _initFuture = _doInitialize();
    return _initFuture;
  }

  Future<void> _doInitialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
    }

    // Request permissions
    await _requestPermissions();
    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Android 13+: request via plugin implementation.
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // For Android 13+ (API level 33+)
    final status = await Permission.notification.status;
    if (status.isDenied) {
      print('Notification permission denied');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _tapStreamController.add(payload);
    }
  }

  String? consumeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  /// Schedule a notification for a todo
  Future<void> scheduleTodoNotification({
    required String id,
    required String title,
    required String description,
    required DateTime scheduledDate,
  }) async {
    await initialize();

    // Cancel existing notification for this todo if any
    await cancelNotification(id);

    // Only schedule if the date is in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      print('Cannot schedule notification for past date');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo tasks',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _notifications.zonedSchedule(
        id: id.hashCode, // Use todo id hash as notification id
        scheduledDate: scheduledTZDate,
        notificationDetails: notificationDetails,
        title: title,
        body: description.isEmpty
            ? 'You have a task to complete!'
            : description,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: id, // Pass todo id as payload
      );
    } catch (_) {
      // Fallback for devices where exact alarm permission is unavailable.
      await _notifications.zonedSchedule(
        id: id.hashCode,
        scheduledDate: scheduledTZDate,
        notificationDetails: notificationDetails,
        title: title,
        body: description.isEmpty
            ? 'You have a task to complete!'
            : description,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: id,
      );
    }

    print('Notification scheduled for: $scheduledDate');
  }

  /// Cancel a notification
  Future<void> cancelNotification(String todoId) async {
    await initialize();
    await _notifications.cancel(id: todoId.hashCode);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await initialize();
    await _notifications.cancelAll();
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo tasks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  void dispose() {
    _tapStreamController.close();
  }
}
