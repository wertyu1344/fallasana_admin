import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseServices {
  static Future<void> saveDataToFirestore(
    String name,
    String title,
    String firstFavoriteLength,
    String category,
    String selectedGender,
    String prompt,
    String firstMessage,
    String id,
  ) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    print("gelen id $id");
    await users.doc(id).set({
      "id": id,
      'name': name,
      'title': title,
      'firstFavoriteLength': firstFavoriteLength,
      'category': category,
      'gender': selectedGender,
      'prompt': prompt,
      'firstMessage': firstMessage,
    }).then((value) {
      print('Data saved successfully!');
    }).catchError((error) {
      print('Failed to save data: $error');
    });
  }

  static Future<void> updateData(
    String name,
    String title,
    String firstFavoriteLength,
    String category,
    String selectedGender,
    String prompt,
    String firstMessage,
    String id,
  ) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    print("gelen id $id");
    await users.doc(id).update({
      "id": id,
      'name': name,
      'title': title,
      'firstFavoriteLength': firstFavoriteLength,
      'category': category,
      'gender': selectedGender,
      'prompt': prompt,
      'firstMessage': firstMessage,
    }).then((value) {
      print('Data saved successfully!');
    }).catchError((error) {
      print('Failed to save data: $error');
    });
  }

  static void deleteData(var id) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(id).delete();
    await FirebaseStorage.instance.ref("image/$id").delete();
  }
}
