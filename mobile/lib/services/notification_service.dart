import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Configuration des notifications locales
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configuration Firebase
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Écouter les messages Firebase
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Obtenir le token FCM
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Écouter les changements de token
    _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);
  }

  static Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);

    // TODO: Envoyer le token au serveur
    print('FCM Token: $token');
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Naviguer vers l'écran approprié
    print('Notification tapped: ${response.payload}');
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    _showLocalNotification(
      title: message.notification?.title ?? 'Caretime',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');

    _showLocalNotification(
      title: message.notification?.title ?? 'Caretime',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'caretime_channel',
      'Caretime Notifications',
      channelDescription: 'Notifications pour les rendez-vous médicaux',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showAppointmentReminder({
    required String doctorName,
    required String appointmentTime,
    required String appointmentId,
  }) async {
    await _showLocalNotification(
      title: 'Rappel de rendez-vous',
      body: 'Votre rendez-vous avec Dr. $doctorName est dans 1 heure',
      payload: 'appointment:$appointmentId',
    );
  }

  static Future<void> showAppointmentConfirmation({
    required String doctorName,
    required String appointmentTime,
  }) async {
    await _showLocalNotification(
      title: 'Rendez-vous confirmé',
      body:
          'Dr. $doctorName a confirmé votre rendez-vous pour $appointmentTime',
    );
  }

  static Future<void> showAppointmentCancellation({
    required String doctorName,
    required String appointmentTime,
  }) async {
    await _showLocalNotification(
      title: 'Rendez-vous annulé',
      body:
          'Votre rendez-vous avec Dr. $doctorName pour $appointmentTime a été annulé',
    );
  }

  static Future<void> showNewMessage({
    required String senderName,
    required String message,
  }) async {
    await _showLocalNotification(
      title: 'Nouveau message de $senderName',
      body: message,
      payload: 'chat:$senderName',
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
