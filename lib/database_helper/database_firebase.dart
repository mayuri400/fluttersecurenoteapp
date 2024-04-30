
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_app/database_helper/database_helper.dart';
import 'package:notes_app/model/note_model.dart';
import 'package:uuid/uuid.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userCollection = "users";
  final String noteCollection = "notes";

  // Future<bool> createNewUser(UserModel user) async {
  //   try {
  //     await _firestore
  //         .collection(userCollection)
  //         .doc(user.id)
  //         .set({"id": user.id, "name": user.name, "email": user.email});
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return true;
  //   }
  // }
  //
  // Future<UserModel> getUser(String uid) async {
  //   try {
  //     DocumentSnapshot doc =
  //     await _firestore.collection(userCollection).doc(uid).get();
  //     return UserModel.fromDocumentSnapshot(doc);
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }


  Future<void> uploadData()async{
    List<Note> notes=await DatabaseHelper.instance.getNoteList();
    await _deleteCollection();
    await addNote(notes);
  }
  Future<void> addNote(List<Note> notes) async {
    try {
      await Future.forEach(notes, (item) async {
        var uuid = const Uuid().v4();
        await _firestore.collection('notes').add({
          "id": uuid,
          "title": item.title,
          "body": item.content,
          "creationDate": Timestamp.now(),
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> _deleteCollection() async {
    final collectionRef = _firestore.collection('notes');

    // Get all documents in the collection
    final querySnapshot = await collectionRef.get();

    // Delete each document in the collection
    final futures = querySnapshot.docs.map((doc) => doc.reference.delete());
    await Future.wait(futures);
  }
}