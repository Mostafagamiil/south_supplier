import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;

// ignore: depend_on_referenced_packages
import 'package:intl/date_symbol_data_local.dart';

import '../../const.dart';

class ItemsDetailsScreen extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  const ItemsDetailsScreen(this.documentSnapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ar_SA', null);
    final timestamp = documentSnapshot['تاريخ الإضافة'] as Timestamp;
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
                documentSnapshot['اسم المنتج'],
                style: const TextStyle(
                  fontFamily: 'Lalezar',
                  color: primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('سعر المنتج: ${documentSnapshot['سعر المنتج'].toString()}',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              Text('تاريخ الإضافة:$addDate',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              Text(
                  'تمت الإضافة بواسطة :  ${documentSnapshot['تمت الإضافة بواسطة']}',
                  style: const TextStyle(
                    fontFamily: 'Lalezar',
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              
            ],
          ),
        ),
      ),
    );
  }
}
