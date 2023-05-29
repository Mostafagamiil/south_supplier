// ignore_for_file: unnecessary_null_comparison

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? route) async {
      if (route != null) {
        Navigator.of(context).pushNamed(route);
      }
    });
  }

  static const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    "southsupply",
    "southsupply channel",
    channelDescription: "this is our channel",
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    ticker: "ticker",
    icon: "@mipmap/ic_launcher",
  );

  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
      "southsupply",
      "southsupply channel",
      channelDescription: "this is our channel",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      playSound: true,
      ticker: "ticker",
      icon: "@mipmap/ic_launcher",
    ));
  }

  static Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    await _notificationsPlugin.initialize(
        InitializationSettings(android: initializationSettingsAndroid));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage(message);
    });

  }

  static void onMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidNotification = message.notification?.android;
    if (notification == null) return;
    if (androidNotification != null && notification != null) {
      _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        _notificationDetails(),
      );
    }
  }

  static void onMessageOpenedApp(BuildContext context, RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? androidNotification = message.notification?.android;
  if (notification == null) return;
  if (androidNotification != null && notification != null) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(notification.title ?? "No title"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body ?? "No body"),
              ],
            ),
          ),
        );
      },
    );
  }
}

}
