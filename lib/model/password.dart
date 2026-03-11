import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordModel {
  String? id;
  String title;
  String password;
  String value2;
  bool value3;
  DateTime created;

  PasswordModel({
     this.id,
    required this.title,
    required this.password,
    required this.value2,
    required this.value3,
    required this.created,
  });

  // Convert Firestore → Model
  factory PasswordModel.fromMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return PasswordModel(
      id: doc.id,
      title: data['title'] ?? '',
      password: data['password'] ?? '',
      value2: data['value2'] ?? '',
      value3: data['value3'] ?? false,
      created: (data['created'] as Timestamp).toDate(),
    );
  }

  // Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "password": password,
      "value2": value2,
      "value3": value3,
      "created": created,
    };
  }
}