// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
//
// import '../model/media_model.dart';
//
// class MediaRepository {
//   final storage = FirebaseStorage.instance;
//   final firestore = FirebaseFirestore.instance;
//
//   Future<String> uploadMedia(File file, String path) async {
//     final ref = storage.ref().child('$path/${Uuid().v4()}');
//     await ref.putFile(file);
//     return await ref.getDownloadURL();
//   }
//
//   Future<void> saveMedia(MediaModel media) async {
//     await firestore.collection('media').add(media.toMap());
//   }
// }