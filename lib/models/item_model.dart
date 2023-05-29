import 'package:cloud_firestore/cloud_firestore.dart';



class ItemModel {
  final String name;
  final double price; // keep type as double
  double? quantity;
  final String id;

  ItemModel({
    required this.name,
    required this.price,
    required this.id,
  });

  factory ItemModel.fromQueryDocument(QueryDocumentSnapshot<Object?> json) {
    return ItemModel(
      id: json.id,
      name: json['اسم المنتج'],
      price: json['سعر المنتج'].toDouble(), // change value to double
    );
  }
}
   

  Map<String, dynamic> toJson() {
    return {
      'name': 'اسم المنتج',
      'price': 'سعر المنتج',
    };
  }

