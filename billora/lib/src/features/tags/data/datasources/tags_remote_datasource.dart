import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:billora/src/features/tags/data/models/tag_model.dart';

abstract class TagsRemoteDataSource {
  Future<List<TagModel>> getAllTags();
  
  Future<TagModel> createTag({
    required String name,
    required String color,
  });
  
  Future<void> updateTag(TagModel tag);
  
  Future<void> deleteTag(String tagId);
  
  Future<List<TagModel>> searchTags(String query);
  
  Future<void> incrementTagUsage(String tagId);
  
  Future<List<TagModel>> getMostUsedTags({int limit = 10});
  
  Future<void> syncTags();
}

@Injectable(as: TagsRemoteDataSource)
class TagsRemoteDataSourceImpl implements TagsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Uuid uuid;

  TagsRemoteDataSourceImpl(this.firestore, this.auth, this.uuid);

  String get _userId => auth.currentUser?.uid ?? '';

  @override
  Future<List<TagModel>> getAllTags() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => TagModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all tags: $e');
    }
  }

  @override
  Future<TagModel> createTag({
    required String name,
    required String color,
  }) async {
    try {
      final tagId = uuid.v4();
      final now = DateTime.now();

      final tagData = {
        'name': name,
        'color': color,
        'usageCount': 0,
        'createdAt': now.millisecondsSinceEpoch,
      };

      await firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .doc(tagId)
          .set(tagData);

      return TagModel.fromJson({
        'id': tagId,
        ...tagData,
      });
    } catch (e) {
      throw Exception('Failed to create tag: $e');
    }
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    try {
      await firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .doc(tag.id)
          .update(tag.toJson());
    } catch (e) {
      throw Exception('Failed to update tag: $e');
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      await firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .doc(tagId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }

  @override
  Future<List<TagModel>> searchTags(String query) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .orderBy('name')
          .get();

      final allTags = querySnapshot.docs
          .map((doc) => TagModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Filter by search query
      return allTags
          .where((tag) =>
              tag.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search tags: $e');
    }
  }

  @override
  Future<void> incrementTagUsage(String tagId) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .doc(tagId);

      await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final data = doc.data()!;
          final currentUsageCount = data['usageCount'] as int? ?? 0;

          transaction.update(docRef, {
            'usageCount': currentUsageCount + 1,
            'lastUsed': DateTime.now().millisecondsSinceEpoch,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to increment tag usage: $e');
    }
  }

  @override
  Future<List<TagModel>> getMostUsedTags({int limit = 10}) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(_userId)
          .collection('tags')
          .orderBy('usageCount', descending: true)
          .orderBy('lastUsed', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => TagModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get most used tags: $e');
    }
  }

  @override
  Future<void> syncTags() async {
    // This method can be used for background sync operations
    // For now, we'll implement basic sync logic
    try {
      // Sync local cache with remote data
      // This can be expanded based on offline requirements
    } catch (e) {
      throw Exception('Failed to sync tags: $e');
    }
  }
} 