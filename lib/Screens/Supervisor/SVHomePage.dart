import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Widgets/Cards/cardCustomer_details.dart';
import '../../const.dart';
import 'AddCustomerScreen.dart';

class SuperVisorHomePage extends StatefulWidget {
  const SuperVisorHomePage({Key? key}) : super(key: key);

  @override
  State<SuperVisorHomePage> createState() => _SuperVisorHomePageState();
}

class _SuperVisorHomePageState extends State<SuperVisorHomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nationalIdController = TextEditingController();
  String _searchText = '';
  final CollectionReference _customerId =
      FirebaseFirestore.instance.collection('CustomerId');
  final _formKey = GlobalKey<FormState>();
  void _performSearch() async {
    if (_searchText.isNotEmpty) {
      QuerySnapshot querySnapshot =
          await _customerId.where('الرقم القومي', isEqualTo: _searchText).get();
      if (querySnapshot.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('نتائج البحث'),
            content: Text('تم العثور على الرقم القومي $_searchText.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا'),
              ),
            ],
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCustomerScreen(
              customerId: _searchText,
              nationalId: _nationalIdController.text, token: '',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              color: secondaryColor,
              icon: const Icon(Icons.logout, color: secondaryColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("تأكيد تسجيل الخروج"),
                      content:
                          const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("إلغاء",
                              style: TextStyle(color: secondaryColor)),
                        ),
                        TextButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          child: const Text("تأكيد",
                              style: TextStyle(color: secondaryColor)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  right: 10,
                  left: 10,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          maxLength: 14,
                          controller: _nationalIdController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'الرقم القومي',
                            labelStyle: const TextStyle(color: primaryColor),
                            fillColor: Colors.white,
                            hintText: 'أدخل الرقم القومي',
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.0),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(
                                'assets/images/number.png',
                                width: 25,
                                height: 25,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value.trim();
                            });
                          },
                          validator: (value) {
                            final RegExp nationalIdRegex = RegExp(
                                r'^([1-9]{1})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})[0-9]{3}([0-9]{1})[0-9]{1}$');
                            if (value == null ||
                                !nationalIdRegex.hasMatch(value) ||
                                value.length > 14) {
                              // Add this line to check the length
                              return 'الرجاء إدخال رقم قومي صحيح ويجب أن يحتوي على 14 رقمًا فقط';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text('بحث'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // form is valid, perform search
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _customerId
                    .where('الرقم القومي', isEqualTo: _searchText)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final documentSnapshot = docs[index];
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  CustomerDetailsScreen(documentSnapshot),
                            );
                          },
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                            ),
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(
                                documentSnapshot['الاسم'],
                                style: const TextStyle(
                                  fontFamily: 'Lalezar',
                                  color: primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                  'الرقم القومي :${documentSnapshot['الرقم القومي'].toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'Lalezar',
                                    color: secondaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  )),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
