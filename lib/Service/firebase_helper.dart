// ignore: unused_import
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';
import 'local_notification_service.dart';

class FirebaseHelper {
  const FirebaseHelper._();

  static Future<void> setupFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await LocalNotificationService.initializeNotification();
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance.subscribeToTopic("all");
  }

  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    await setupFirebase();
    print("Handling a background message: ${message.notification}");
  }

  static Future<void> testHealth() async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('checkHealth');

    final response = await callable.call();

    if (response.data == "ok") {
      print(response);
    }
  }

  static Future<bool> sendNotification({
    required String title,
    required String body,
    required String token,
    required DateTime timestamp,
  }) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');

    try {
      final response = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
        'token': token,
        'seen': false,
        'opened': false,
      });

      if (response.data == "ok") {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': title,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      print('There was an error: $e');
      return false;
    }
  }
}
