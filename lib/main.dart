// ignore: depend_on_referenced_packages
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:southsupply/Screens/Admin/Add_Item.dart';
import 'package:southsupply/Screens/Supervisor/SVHomePage.dart';
import 'Service/firebase_helper.dart';
import 'Service/local_notification_service.dart';
import 'Widgets/custom_text.dart';
import 'const.dart';
import 'firebase_options.dart';
import 'main_page.dart';

///Receive message when is in background solution for om message tapped by user on background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseHelper.setupFirebase();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await LocalNotificationService.initializeNotification();
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await initializeDateFormatting("ar_SA", null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: newSplashScreen(),
        routes: {
          "admin": (_) => const HomePage(),
          'supervisor': (_) => const SuperVisorHomePage(),
        },
      ),
    );
  }
}

// ignore: camel_case_types
class newSplashScreen extends StatelessWidget {
  const newSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const customText(
                text: 'South',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              const customText(
                text: 'suppliers',
                fontSize: 32,
                fontWeight: FontWeight.normal,
                color: secondaryColor,
              ),
              Image.asset("assets/images/hi.gif",
                  height: 70, width: 100, fit: BoxFit.cover),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      nextScreen: const MainPage(),
    );
  }
}
