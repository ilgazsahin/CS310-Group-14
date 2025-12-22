import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';

class PostProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<PostModel>> get allPosts => _firestoreService.getPostsStream();
  Stream<List<PostModel>> get myPosts => _firestoreService.getUserPostsStream();

  Future<String> createPost(PostModel post) async {
    try {
      final postId = await _firestoreService.createPost(post);
      notifyListeners();
      return postId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePost(String postId, PostModel post) async {
    try {
      await _firestoreService.updatePost(postId, post);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestoreService.deletePost(postId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ========== LIKES ==========

  Future<bool> hasUserLikedPost(String postId) async {
    return await _firestoreService.hasUserLikedPost(postId);
  }

  Future<void> toggleLikePost(String postId) async {
    try {
      await _firestoreService.toggleLikePost(postId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ========== COMMENTS ==========

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestoreService.getCommentsStream(postId);
  }

  Future<String> createComment(CommentModel comment) async {
    try {
      final commentId = await _firestoreService.createComment(comment);
      notifyListeners();
      return commentId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _firestoreService.deleteComment(commentId, postId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  bool canUserDeleteComment(CommentModel comment) {
    return _firestoreService.canUserDeleteComment(comment);
  }
}

