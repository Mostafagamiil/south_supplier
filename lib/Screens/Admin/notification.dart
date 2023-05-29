import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:southsupply/const.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:ui';
import '../../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Stream<List<NotificationModel>> _notificationsStream;
  final dateFormat = intl.DateFormat('dd MMMM yyyy', 'ar');
  final hourMinuteFormat = intl.DateFormat('HH:mm', 'ar');
  DocumentSnapshot?
      _lastLoadedDocument; // Variable to store the last loaded document
  bool _isLoadingMore = false; // Flag to track if more data is being loaded

  ScrollController _scrollController = ScrollController();
  List<NotificationModel> notifications = []; // List to store the notifications

  @override
  void initState() {
    super.initState();
    _notificationsStream = getNotificationsStream();
    _scrollController.addListener(_scrollListener);
  }

  Stream<List<NotificationModel>> getNotificationsStream() {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(10);

    if (_lastLoadedDocument != null) {
      query = query.startAfterDocument(_lastLoadedDocument!);
    }

    return query.snapshots().map((snapshot) {
      final documents = snapshot.docs.map((doc) {
        final notification = NotificationModel.fromQueryDocument(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>);
        return notification;
      }).toList();
      if (documents.isNotEmpty) {
        _lastLoadedDocument = snapshot.docs.last;
      }
      return documents;
    });
  }

  Future<void> loadMoreNotifications() async {
    if (_lastLoadedDocument == null) return;

    final query = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastLoadedDocument!)
        .limit(10);

    final snapshot = await query.get();
    final documents = snapshot.docs.map((doc) {
      final notification = NotificationModel.fromQueryDocument(
          doc as QueryDocumentSnapshot<Map<String, dynamic>>);
      return notification;
    }).toList();

    if (documents.isNotEmpty) {
      setState(() {
        notifications.addAll(documents);
        _lastLoadedDocument = snapshot.docs.last;
      });
    } else {
      _lastLoadedDocument = null;
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Scrolled to the bottom, load more data
      _loadMoreData();
    }
  }

  void _loadMoreData() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      await loadMoreNotifications();
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final title = notification.title;
    final body = notification.body;
    final timestamp = notification.timestamp;
    final formattedDate = dateFormat.format(timestamp);
    final formattedHourMinute = hourMinuteFormat.format(timestamp);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          subtitle: Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '$formattedDate $formattedHourMinute',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: double.infinity,
          height: 100,
          color: Colors.grey.withOpacity(0.3),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'الإشعارات',
            style: TextStyle(color: secondaryColor),
          ),
          iconTheme: const IconThemeData(
            color: secondaryColor,
          ),
        ),
        body: StreamBuilder<List<NotificationModel>>(
          stream: _notificationsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            notifications = snapshot.data!;

            return ListView.builder(
              controller: _scrollController,
              itemCount: notifications.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < notifications.length) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification);
                } else if (_isLoadingMore) {
                  return _buildLoadingCard();
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
