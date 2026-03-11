
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:password_saver/model/password.dart';
class Repository{


  Future<bool> addToDb(String newPassword, String title) async {
    try {
      await FirebaseFirestore.instance
          .collection("passwords")
          .add({
        "title": title,
        "password": newPassword,
        "value2": "",
        "value3": false,
        "created": DateTime.now()
      });

      return true;

    } catch (e) {

      print(e);
      return false;

    }

  }
  Future<bool> update(String newPassword, String title,docID) async {
    try {
      await FirebaseFirestore.instance
          .collection("passwords")
          .doc(docID).update(
          ({
            "title": title,
            "password": newPassword,
            "value2": "",
            "value3": false,
            "created": DateTime.now()
          })
      );

      return true;

    } catch (e) {

      print(e);
      return false;

    }

  }

  Future<List<PasswordModel>> fetchList() async {

    final response = await FirebaseFirestore.instance
        .collection("passwords")
        .get();

    return response.docs
        .map((e) => PasswordModel.fromMap(e))
        .toList();
  }


}