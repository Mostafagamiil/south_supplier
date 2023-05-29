import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Screens/Admin/AdminHomePage.dart';
import 'Screens/Supervisor/SVHomePage.dart';
import 'login_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final User? user = snapshot.data;
            if (user != null) {
              final String email = user.email!;
              if (email.endsWith('@admin.com')) {
                return const AdminHome();
              } else if (email.endsWith('@supervisor.com')) {
                return const SuperVisorHomePage();
              } else {
                // User has an invalid email address
                FirebaseAuth.instance.signOut();
                return const Text('Invalid email address!');
              }
            } else {
              // This should not happen, but just in case
              FirebaseAuth.instance.signOut();
              return const AdminloginScreen();
            }
          } else {
            return const AdminloginScreen();
          }
        },
      ),
    );
  }
}
