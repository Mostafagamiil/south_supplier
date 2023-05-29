import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String title;
  final String body;
  final String id;
  final DateTime timestamp;

  NotificationModel( {
    required this.timestamp,
    required this.title,
    required this.body,
    required this.id,
  });

factory NotificationModel.fromQueryDocument(QueryDocumentSnapshot<Map<String, dynamic>> json) {
  return NotificationModel(
    id: json.id,
    title: json.data()['title'] as String,
    body: json.data()['body'] as String,
    timestamp: (json.data()['timestamp'] as Timestamp).toDate(),
  );
}
  
    Map<String, dynamic> toJson() {
      return {
        'title': title,
        'body': body,
        'timestamp': timestamp,
      };
    }

    


}
