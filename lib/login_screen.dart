import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'Widgets/custom_text.dart';
import 'const.dart';


class AdminloginScreen extends StatefulWidget {
  const AdminloginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminloginScreenState createState() => _AdminloginScreenState();
}

class _AdminloginScreenState extends State<AdminloginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _selectedRole = 0;

  final List<String> _roles = ['Admin', 'Supervisor'];

Future<void> _signIn() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  String domain = '${_roles[_selectedRole].toLowerCase()}.com';
  String email = '${_emailController.text.trim()}@$domain';
  if (!email.endsWith('@$domain')) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Email'),
        content: const Text('Please enter a valid email for your selected role.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: const TextStyle(color: primaryColor),
            ),
          )
        ],
      ),
    );
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text.trim(),
    );

    // Get the current user
    User? user = userCredential.user;

    // Check if the user is an admin or supervisor
    bool isAdmin = _selectedRole == 0;
    bool isSupervisor = _selectedRole == 1;

    // Save the email and token in the respective table in Firebase
    if (isAdmin || isSupervisor) {
      String tableName = isAdmin ? 'admin' : 'supervisor';
      String? token = await FirebaseMessaging.instance.getToken();

      // Create a new document with the user's email and token
      await FirebaseFirestore.instance
          .collection(tableName)
          .doc(user!.uid)
          .set({
            'email': user.email,
            'token': token,
            'uid': user.uid,
          });
    }
  } on FirebaseAuthException catch (e) {
    String message = '';
    if (e.code == 'user-not-found') {
      message = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password provided for that user.';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email provided.';
    } else {
      message = 'An error occurred while logging in. Please try again later.';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: primaryColor),
            ),
          )
        ],
      ),
    );
  }
}


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(
                  top: 100,
                  right: 10,
                  left: 10,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/user (1).png",
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: const [
                            customText(
                              text: "أهلا بك",
                              fontSize: 40,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    // ignore: prefer_const_constructors
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'رجاء ادخل أسم المستخدم';
                          } else if (!RegExp(r'^[\w-]+$').hasMatch(value)) {
                            return 'رجاء ادخال اسم مستخدم ساري';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'أدخل أسم المستخدم',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // ignore: prefer_const_constructors
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'رجاء ادخل كلمة السر';
                          }
                          return null;
                        },
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'أدخل كلمة السر',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          customText(
                            text: "أدخل وظيفتك ",
                            fontSize: 20,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: List<Widget>.generate(
                              _roles.length,
                              (int index) {
                                return Expanded(
                                  child: RadioListTile<int>(
                                    activeColor: primaryColor,
                                    title: customText(
                                      text: _roles[index],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    value: index,
                                    groupValue: _selectedRole,
                                    onChanged: (int? value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                        onTap: _signIn,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'تسجيل دخول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),                    
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
