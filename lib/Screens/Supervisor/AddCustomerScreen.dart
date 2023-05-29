import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Service/firebase_helper.dart';
import '../../const.dart';
import '../../models/item_model.dart';

class AddCustomerScreen extends StatefulWidget {
  final String customerId;
  final String nationalId;
  final String token;
  const AddCustomerScreen(
      {Key? key,
      required this.customerId,
      required this.nationalId,
      required this.token})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference _customerId =
      FirebaseFirestore.instance.collection('CustomerId');
  bool _isLoading = false;
  void _setSearchString(String value) {
    setState(() {
    });
  }

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('items');
  final TextEditingController _nameController = TextEditingController();
  TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final List<ItemModel> _itemsList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _quantityControllers = [];
  String _name = '';
  String _nationalId = '';

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nationalId = widget.nationalId;
    _nationalIdController = TextEditingController(text: _nationalId);
  }

  Future<List<String>> getAdminTokens() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('admin').get();

    List<String> tokens = [];

    snapshot.docs.forEach((doc) {
      String token = doc['token'];
      tokens.add(token);
    });

    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: SizedBox(
          height: 100,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      bool allQuantitiesValid = true;
                      bool anyQuantityEntered = false;
                      Map<String, dynamic> userItems = {};
                      double totalPrice = 0.0;

                      for (int i = 0; i < _itemsList.length; i++) {
                        DocumentSnapshot documentSnapshot =
                            await FirebaseFirestore.instance
                                .collection('items')
                                .doc(_itemsList[i].id)
                                .get();
                        int currentQuantity =
                            documentSnapshot['كمية المنتج'].toInt();

                        int userQuantity =
                            int.tryParse(_quantityControllers[i].text) ?? 0;

                        if (userQuantity > 0) {
                          anyQuantityEntered = true;
                          if (userQuantity > currentQuantity) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'الكمية المدخلة أكبر من الكمية المتاحة للمنتج ${_itemsList[i].name}',
                              ),
                            ));
                            allQuantitiesValid = false;
                            break;
                          } else {
                            if (currentQuantity - userQuantity <= 20) {
                              String itemName = _itemsList[i].name;

                              List<String> adminTokens = await getAdminTokens();
                              adminTokens.forEach((token) {
                                FirebaseHelper.sendNotification(
                                  title: 'الرجاء إعادة تعبئة $itemName',
                                  body: 'كمية المنتج $itemName قليلة.',
                                  timestamp: DateTime.now(),
                                  token: token,
                                );
                              });

                              // Save the notification in Firestore
                              await FirebaseFirestore.instance
                                  .collection('notifications')
                                  .add({
                                'title': 'الرجاء إعادة تعبئة $itemName',
                                'body': 'The quantity of $itemName is low.',
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            }
                            userItems[_itemsList[i].name] =
                                userQuantity.toString();
                            double pricePerItem =
                                documentSnapshot['سعر المنتج'].toDouble();
                            totalPrice += pricePerItem * userQuantity;
                            int newQuantity = currentQuantity - userQuantity;
                            FirebaseFirestore.instance
                                .collection('items')
                                .doc(_itemsList[i].id)
                                .update({'كمية المنتج': newQuantity});
                            print(
                                "${_itemsList[i].name} : ${userQuantity.toString()}");
                          }
                        }
                      }

                      if (!anyQuantityEntered) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('يرجى إدخال كميات للمنتجات المراد شراؤها'),
                        ));
                        setState(() {
                          _isLoading = false;
                        });
                      } else if (allQuantitiesValid) {
                        setState(() {
                          _isLoading = true;
                        });

                        Map<String, dynamic> userInformation = {
                          'الاسم': _name,
                          'الرقم القومي': _nationalId,
                          'تاريخ الإضافة': DateTime.now(),
                          'تمت الإضافة بواسطة': _auth.currentUser!.email,
                          'إجمالي السعر': totalPrice.toStringAsFixed(2),
                        };

                        Map<String, dynamic> userMap = {
                          ...userInformation,
                          ...userItems,
                        };
                        setState(() {
                          _isLoading = false;
                        });
                        _customerId.doc(widget.customerId).set(userMap);

                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                secondaryColor,
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'أضافة العميل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            color: secondaryColor,
            icon: const Icon(
              Icons.arrow_back,
              color: secondaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                right: 10,
                left: 10,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          labelStyle: const TextStyle(color: primaryColor),
                          fillColor: Colors.white,
                          hintText: 'أدخل الاسم الثلاثي',
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'assets/images/commodity.png',
                              width: 25,
                              height: 25,
                              color: secondaryColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'من فضلك أدخل الاسم';
                          } else if (!RegExp(r'^[\u0600-\u06FF\s]+$')
                              .hasMatch(value)) {
                            return 'يجب إدخال حروف عربية فقط';
                          } else {
                            final parts = value.split(' ');
                            if (parts.length < 3) {
                              return 'يجب إدخال الاسم الثلاثي';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _name = value.trim();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _nationalIdController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        maxLength:
                            14, // Add this line to set the maximum length
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
                              color: secondaryColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (value) {
                          final RegExp nationalIdRegex = RegExp(
                              r'^([1-9]{1})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})[0-9]{3}([0-9]{1})[0-9]{1}$');
                          if (value == null ||
                              !nationalIdRegex.hasMatch(value)) {
                            return 'الرجاء إدخال رقم قومي صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _nationalId = value.trim();
                          });
                        },
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _items.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        final data = snapshot.data;
                        if (data == null || data.docs.isEmpty) {
                          return const Center(
                            child: Text('No items found'),
                          );
                        }
                        return RefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(const Duration(seconds: 1));
                              setState(() {});
                            },
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...List.generate(data.docs.length, (index) {
                                    _quantityControllers
                                        .add(TextEditingController());
                                    final documentSnapshot = data.docs[index];
                                    final itemExists = _itemsList.any(
                                        (element) =>
                                            element.name ==
                                            documentSnapshot["اسم المنتج"]);

                                    if (!itemExists) {
                                      _itemsList.add(
                                          ItemModel.fromQueryDocument(
                                              documentSnapshot));
                                    }
                                    final item = _itemsList[index];
                                    return Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Column(
                                        children: [
                                          Card(
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            margin: const EdgeInsets.all(10),
                                            child: ListTile(
                                              title: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Lalezar',
                                                  color: primaryColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'سعر المنتج: ${item.price.toString()}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Lalezar',
                                                      color: Colors.black54,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller:
                                                              _quantityControllers[
                                                                  index],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: 'الكمية',
                                                            labelStyle:
                                                                const TextStyle(
                                                                    color:
                                                                        primaryColor),
                                                            fillColor:
                                                                Colors.white,
                                                            hintText:
                                                                'أدخل الكمية',
                                                            focusedBorder:
                                                                const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          primaryColor,
                                                                      width:
                                                                          2.0),
                                                            ),
                                                            prefixIcon: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      15.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/number.png',
                                                                width: 25,
                                                                height: 25,
                                                                color:
                                                                    secondaryColor,
                                                              ),
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              _quantityControllers[
                                                                      index]
                                                                  .text = '0';
                                                              return null;
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        documentSnapshot[
                                                            'وحدة المنتج'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Lalezar',
                                                          color: Colors.black54,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
