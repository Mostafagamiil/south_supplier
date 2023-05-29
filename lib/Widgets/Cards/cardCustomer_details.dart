import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;

// ignore: depend_on_referenced_packages
import 'package:intl/date_symbol_data_local.dart';
import '../../../const.dart';
import '../custom_text.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const CustomerDetailsScreen(this.documentSnapshot, {super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  // ignore: override_on_non_overriding_member
  List<Map<String, dynamic>> _list = [];
  //TODO: edit customer display card
  initState() {
    var myMap = widget.documentSnapshot.data() as Map<String, dynamic>;
    myMap.forEach((key, value) {
      if (key != 'تاريخ الإضافة' &&
          key != 'تمت الإضافة بواسطة' &&
          key != 'الرقم القومي' &&
          key != "الاسم" &&
          key != 'إجمالي السعر') _list.add({key: value});
    });

    _list = _list.where((element) {
      print(element.values.first);
      print(element.values.first == '0');
      if (element.values.first == '0') {
        return false;
      } else {
        return true;
      }
    }).toList();
    super.initState();
  }

  Widget build(BuildContext context) {
    initializeDateFormatting('ar_SA', null);
    final timestamp = widget.documentSnapshot['تاريخ الإضافة'] as Timestamp;
    final addDate = intl.DateFormat('yyyy-MM-dd  hh:mm a', 'ar_SA')
        .format(timestamp.toDate());
    return Container(
      color: const Color(0xff757575),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Text(
                'الاسم:   ${widget.documentSnapshot['الاسم']}',
                style: const TextStyle(
                  fontFamily: 'Lalezar',
                  color: primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('الرقم القومي:   ${widget.documentSnapshot['الرقم القومي']}',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              Text('تاريخ الإضافة:   $addDate',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              Text(
                  'تمت الإضافة بواسطة :  ${widget.documentSnapshot['تمت الإضافة بواسطة']}',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              const SizedBox(
                height: 10,
              ),
              const customText(
                  text: 'المنتجات المباعة :',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.background,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: FittedBox(
                                  child: Text(_list[index].keys.first))),
                          Expanded(
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                      _list[index].values.first.toString()))),
                        ],
                      ),
                      //   ],
                      // ),
                    );
                  },
                ),
              ),
              Text('إجمالي السعر:   ${widget.documentSnapshot['إجمالي السعر']}',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),

              // Add more Text widgets to display the other fields in the document
            ],
          ),
        ),
      ),
    );
  }
}
