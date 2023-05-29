import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';

import '../../const.dart';
import '../skeleton.dart';

class NotificationCard extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  const NotificationCard({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ar_SA', null);
    final timestamp = documentSnapshot['تاريخ الإضافة'] as Timestamp;
    // ignore: unused_local_variable
    final addDate = intl.DateFormat('yyyy-MM-dd  hh:mm a', 'ar_SA')
        .format(timestamp.toDate());
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Skeleton(),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentSnapshot['title'],
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding / 2),
                    child: Text(
                      "On politics with Lisa Loureniani: Warren’s growing crowds",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        "Politics",
                        style: TextStyle(color: primaryColor),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: defaultPadding / 2),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      Text(
                        "3m ago",
                        style: TextStyle(color: grayColor),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
