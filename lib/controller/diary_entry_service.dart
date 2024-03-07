// import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../model/diary_entry_model.dart';

class DiaryService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference diaryEntriesCollection;

  DiaryService()
      : diaryEntriesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('diaryEntries');

  Future<DocumentReference<Object?>> addNewEntry(DiaryEntry entry) async {
    if (entry.desc == '') {
      throw Exception('Description cannot be empty');
    } else if (await entryExists(entry.date)) {
      throw Exception('Entry already exists for this date');
    }
    return await diaryEntriesCollection.add(entry.toMap());
  }

  getUserEntriesList() async {
    QuerySnapshot querySnapshot =
        await diaryEntriesCollection.orderBy('date', descending: true).get();
    List<DiaryEntry> res = [];
    querySnapshot.docs.forEach((doc) {
      res.add(DiaryEntry.fromMap(doc));
    });
    return res;
  }

  Stream<List<DiaryEntry>> getUserEntries() {
    return diaryEntriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DiaryEntry.fromMap(doc);
      }).toList();
    });
  }

  Future<void> updateEntry(String id, DiaryEntry entry) async {
    if (await entryExists(entry.date)) {
      throw Exception('Entry already present');
    }
    return await diaryEntriesCollection.doc(id).update(entry.toMap());
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    if (!await entryExists(entry.date)) {
      throw Exception('No entry found for this date');
    }
    return await diaryEntriesCollection.doc(entry.id).delete();
  }

  Future<bool> entryExists(DateTime date) async {
    var entries = [];
    await diaryEntriesCollection.get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        var entry = doc.data();
        entries.add(entry);
      });
    });
    for (var element in entries) {
      if (DateTime.parse(element['date'].toDate().toString()) == date) {
        return true;
      }
    }
    return false;
  }

  Future<String?> uploadImageToFirebase(XFile? image) async {
    if (image == null) return null;
    if (user == null) return null;
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/${user!.uid}/${image.name}');
    try {
      final uploadTask = await firebaseStorageRef.putFile(File(image.path));
      if (uploadTask.state == TaskState.success) {
        final downloadURL = await firebaseStorageRef.getDownloadURL();
        print("Uploaded to: $downloadURL");
        return downloadURL;
      }
    } catch (e) {
      throw Exception("$e: Failed to upload image");
    }
    return null;
  }
}
