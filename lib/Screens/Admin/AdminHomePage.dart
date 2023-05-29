import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../Widgets/Cards/cardCustomer_details.dart';
import '../../const.dart';
import 'Add_Item.dart';
import 'notification.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // ignore: unused_field
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference _customerId =
      FirebaseFirestore.instance.collection('CustomerId');
  late Stream<QuerySnapshot> _customersStream;
  // ignore: unused_field
  late Stream<QuerySnapshot> _notificationsStream;
  String _query = '';

  @override
  void initState() {
    _customersStream = _customerId.snapshots(); 
    _notificationsStream = FirebaseFirestore.instance
      .collection('Notifications')
      .orderBy('timestamp', descending: true)
      .snapshots();
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: const SizedBox.shrink(),
          actions: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                icon: Image.asset(
                  'assets/images/box.png',
                  // color: primaryColor,
                ),
              ),
              
            ),
            const Spacer(),
            IconButton(
              color: secondaryColor,
              icon: const Icon(
                Icons.logout,
                color: secondaryColor,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('تأكيد الخروج'),
                      content:
                          const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(color: secondaryColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'تأكيد',
                            style: TextStyle(color: secondaryColor),
                          ),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
             IconButton(
            color: secondaryColor,
            icon: const Icon(
              Icons.notifications,
              color: secondaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                maxLength: 14,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'الرقم القومي',
                  labelStyle: const TextStyle(color: primaryColor),
                  fillColor: Colors.white,
                  hintText: 'أدخل الرقم القومي',
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2.0),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      'assets/images/number.png',
                      width: 25,
                      height: 25,
                      color: secondaryColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
            
            Expanded(
              
              child: StreamBuilder<QuerySnapshot>(
                stream: _customersStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  _notificationsStream = FirebaseFirestore.instance
    .collection('Notifications')
    .orderBy('timestamp', descending: true)
    .snapshots();

                  final docs = snapshot.data!.docs;
                  final filteredDocs = docs
                      .where((doc) =>
                          doc['الاسم']
                              .toLowerCase()
                              .contains(_query.toLowerCase()) ||
                          doc['الرقم القومي']
                              .toLowerCase()
                              .contains(_query.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final documentSnapshot = filteredDocs[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                CustomerDetailsScreen(documentSnapshot),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  documentSnapshot['الاسم'],
                                  style: const TextStyle(
                                    fontFamily: 'Lalezar',
                                    color: primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'الرقم القومي :${documentSnapshot['الرقم القومي'].toString()}',
                                    style: const TextStyle(
                                      fontFamily: 'Lalezar',
                                      color: secondaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

