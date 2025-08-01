import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../features/user/data/model/media_model.dart';
import '../../features/user/data/model/profile_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  Future<String> uploadMedia(File file, MediaType type, String userId) async {
    try {
      final mediaId = _uuid.v4();
      final extension = type == MediaType.image ? 'jpg' : 'mp4';
      final path = '${type.name}s/$userId/$mediaId.$extension';

      final ref = _storage.ref().child(path);
      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  // Save media item to Firestore
  Future<void> saveMediaItem(MediaItem mediaItem) async {
    try {
      await _firestore
          .collection('media')
          .doc(mediaItem.id)
          .set(mediaItem.toJson());
    } catch (e) {
      throw Exception('Failed to save media item: $e');
    }
  }

  Stream<List<MediaItem>> getUserMediaItems(String userId) {
    return _firestore
        .collection('media')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MediaItem.fromJson(doc.data())).toList());
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<void> updateProfileStats(
      String userId, {
        int? followingCount,
        int? followersCount,
        int? likesCount,
      }) async {
    try {
      final updateData = <String, dynamic>{};
      if (followingCount != null) updateData['followingCount'] = followingCount;
      if (followersCount != null) updateData['followersCount'] = followersCount;
      if (likesCount != null) updateData['likesCount'] = likesCount;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile stats: $e');
    }
  }
}
