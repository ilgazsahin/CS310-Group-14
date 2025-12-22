import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/data_models.dart';
import 'auth_service.dart';

/// Service class to handle Firestore CRUD operations for Events
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get current user
  User? get currentUser => _authService.currentUser;

  // Collection reference
  CollectionReference get _eventsCollection => _firestore.collection('events');

  /// CREATE: Add a new event to Firestore
  Future<String> createEvent(EventModel event) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to create events';
      }

      // Ensure createdBy is set to current user ID
      final eventWithUser = event.copyWith(
        createdBy: user.uid,
        createdAt: DateTime.now(),
      );

      final eventData = eventWithUser.toFirestore();
      print('Creating event with data: $eventData'); // Debug log
      print('User UID: ${user.uid}'); // Debug log

      final docRef = await _eventsCollection.add(eventData);
      print('Event created with ID: ${docRef.id}'); // Debug log

      // Verify the document was created
      final createdDoc = await docRef.get();
      if (createdDoc.exists) {
        print('Event document verified in Firestore'); // Debug log
      } else {
        throw 'Event document was not created in Firestore';
      }

      return docRef.id;
    } catch (e) {
      print('Firestore error: $e'); // Debug log
      // Provide more detailed error message
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'Permission denied. Please check Firestore security rules are deployed correctly.';
      } else if (e.toString().contains('UNAUTHENTICATED')) {
        throw 'You must be logged in to create events.';
      }
      throw 'Failed to create event: ${e.toString()}';
    }
  }

  /// READ: Get a single event by ID
  Future<EventModel?> getEvent(String eventId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to view events';
      }

      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get event: ${e.toString()}';
    }
  }

  /// READ: Get all events (real-time stream)
  Stream<List<EventModel>> getEventsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      // Return empty stream if user is not authenticated
      return Stream.value([]);
    }

    return _eventsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('Error in getEventsStream: $error');
          throw error;
        });
  }

  /// READ: Get events by category (real-time stream)
  Stream<List<EventModel>> getEventsByCategoryStream(String category) {
    final user = _authService.currentUser;
    if (user == null) {
      // Return empty stream if user is not authenticated
      return Stream.value([]);
    }

    return _eventsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('Error in getEventsByCategoryStream: $error');
          throw error;
        });
  }

  /// READ: Get events created by current user (real-time stream)
  Stream<List<EventModel>> getUserEventsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // Query by createdBy and sort in memory (works without composite index)
    // Note: For better performance with large datasets, create a composite index:
    // Collection: events, Fields: createdBy (Ascending), createdAt (Descending)
    return _eventsCollection
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList();
          // Sort by createdAt descending in memory
          events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return events;
        });
  }

  /// UPDATE: Update an existing event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to update events';
      }

      // Get the existing event to verify ownership
      final existingEvent = await getEvent(eventId);
      if (existingEvent == null) {
        throw 'Event not found';
      }

      if (existingEvent.createdBy != user.uid) {
        throw 'You can only update your own events';
      }

      // Update with new timestamp
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());

      await _eventsCollection.doc(eventId).update(updatedEvent.toFirestore());
    } catch (e) {
      throw 'Failed to update event: ${e.toString()}';
    }
  }

  /// DELETE: Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to delete events';
      }

      // Get the existing event to verify ownership
      final existingEvent = await getEvent(eventId);
      if (existingEvent == null) {
        throw 'Event not found';
      }

      if (existingEvent.createdBy != user.uid) {
        throw 'You can only delete your own events';
      }

      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      throw 'Failed to delete event: ${e.toString()}';
    }
  }

  /// Check if user can edit/delete an event
  bool canUserModifyEvent(EventModel event) {
    final user = _authService.currentUser;
    if (user == null) return false;
    return event.createdBy == user.uid;
  }

  // ========== TICKET OPERATIONS ==========

  // Collection reference for tickets
  CollectionReference get _ticketsCollection =>
      _firestore.collection('tickets');

  /// CREATE: Create a ticket for an event
  Future<String> createTicket(EventModel event) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to create tickets';
      }

      if (event.id == null) {
        throw 'Event ID is required to create a ticket';
      }

      // Check if user already has a ticket for this event
      final existingTickets = await _ticketsCollection
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: event.id)
          .get();

      if (existingTickets.docs.isNotEmpty) {
        throw 'You already have a ticket for this event';
      }

      // Create ticket with denormalized event data
      final ticket = TicketModel(
        eventId: event.id!,
        eventTitle: event.title,
        eventLocation: event.location,
        eventDate: event.date,
        eventTime: event.time,
        eventImageUrl: event.imageUrl,
        eventCategory: event.category,
        eventHosts: event.hosts,
        ticketPrice: event.ticketPrice,
        userId: user.uid,
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      final ticketData = ticket.toFirestore();
      final docRef = await _ticketsCollection.add(ticketData);
      return docRef.id;
    } catch (e) {
      throw 'Failed to create ticket: ${e.toString()}';
    }
  }

  /// READ: Get all tickets for current user (real-time stream)
  Stream<List<TicketModel>> getUserTicketsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _ticketsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc))
              .toList();
        });
  }

  /// READ: Check if user has a ticket for an event
  Future<bool> userHasTicket(String eventId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final tickets = await _ticketsCollection
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      return tickets.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// UPDATE: Toggle favorite status of a ticket
  Future<void> toggleTicketFavorite(String ticketId, bool isFavorite) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to update tickets';
      }

      // Verify ownership
      final ticketDoc = await _ticketsCollection.doc(ticketId).get();
      if (!ticketDoc.exists) {
        throw 'Ticket not found';
      }

      final ticketData = ticketDoc.data() as Map<String, dynamic>;
      if (ticketData['userId'] != user.uid) {
        throw 'You can only update your own tickets';
      }

      await _ticketsCollection.doc(ticketId).update({'isFavorite': isFavorite});
    } catch (e) {
      throw 'Failed to update ticket: ${e.toString()}';
    }
  }

  /// DELETE: Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to delete tickets';
      }

      // Verify ownership
      final ticketDoc = await _ticketsCollection.doc(ticketId).get();
      if (!ticketDoc.exists) {
        throw 'Ticket not found';
      }

      final ticketData = ticketDoc.data() as Map<String, dynamic>;
      if (ticketData['userId'] != user.uid) {
        throw 'You can only delete your own tickets';
      }

      await _ticketsCollection.doc(ticketId).delete();
    } catch (e) {
      throw 'Failed to delete ticket: ${e.toString()}';
    }
  }

  // ========== FAVORITE EVENTS OPERATIONS ==========

  // Collection reference for favorites
  CollectionReference get _favoritesCollection =>
      _firestore.collection('favorites');

  /// CREATE: Add an event to favorites
  Future<void> addFavoriteEvent(String eventId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to favorite events';
      }

      // Check if already favorited
      final existingFavorites = await _favoritesCollection
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (existingFavorites.docs.isNotEmpty) {
        throw 'Event is already in your favorites';
      }

      // Add to favorites
      await _favoritesCollection.add({
        'userId': user.uid,
        'eventId': eventId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Failed to add favorite: ${e.toString()}';
    }
  }

  /// DELETE: Remove an event from favorites
  Future<void> removeFavoriteEvent(String eventId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to remove favorites';
      }

      // Find the favorite document
      final favorites = await _favoritesCollection
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (favorites.docs.isEmpty) {
        throw 'Event is not in your favorites';
      }

      // Delete the favorite document
      await _favoritesCollection.doc(favorites.docs.first.id).delete();
    } catch (e) {
      throw 'Failed to remove favorite: ${e.toString()}';
    }
  }

  /// READ: Check if user has favorited an event
  Future<bool> isEventFavorited(String eventId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final favorites = await _favoritesCollection
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      return favorites.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// READ: Get all favorite events for current user (real-time stream)
  Stream<List<EventModel>> getFavoriteEventsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _favoritesCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // Get all event IDs from favorites
          final eventIds = snapshot.docs
              .map(
                (doc) =>
                    (doc.data() as Map<String, dynamic>)['eventId'] as String,
              )
              .toList();

          if (eventIds.isEmpty) {
            return <EventModel>[];
          }

          // Fetch all events in parallel
          final eventFutures = eventIds.map((eventId) => getEvent(eventId));
          final events = await Future.wait(eventFutures);

          // Filter out null events (in case an event was deleted)
          return events.whereType<EventModel>().toList();
        });
  }

  // ========== POST OPERATIONS ==========

  // Collection reference for posts
  CollectionReference get _postsCollection => _firestore.collection('posts');

  /// CREATE: Add a new post to Firestore
  Future<String> createPost(PostModel post) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to create posts';
      }

      // Ensure createdBy is set to current user ID
      // Keep authorName if provided, otherwise use email display name
      final postWithUser = post.copyWith(
        createdBy: user.uid,
        createdAt: DateTime.now(),
        // authorName is already set in the post model from the form
      );

      final postData = postWithUser.toFirestore();
      final docRef = await _postsCollection.add(postData);
      return docRef.id;
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'Permission denied. Please check Firestore security rules are deployed correctly.';
      } else if (e.toString().contains('UNAUTHENTICATED')) {
        throw 'You must be logged in to create posts.';
      }
      throw 'Failed to create post: ${e.toString()}';
    }
  }

  /// READ: Get a single post by ID
  Future<PostModel?> getPost(String postId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to view posts';
      }

      final doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        return PostModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get post: ${e.toString()}';
    }
  }

  /// READ: Get all posts (real-time stream)
  Stream<List<PostModel>> getPostsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PostModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('Error in getPostsStream: $error');
          throw error;
        });
  }

  /// READ: Get posts created by current user (real-time stream)
  Stream<List<PostModel>> getUserPostsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // Query with composite index: createdBy + createdAt
    return _postsCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PostModel.fromFirestore(doc))
              .toList();
        });
  }

  /// UPDATE: Update an existing post
  Future<void> updatePost(String postId, PostModel post) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to update posts';
      }

      // Get the existing post to verify ownership
      final existingPost = await getPost(postId);
      if (existingPost == null) {
        throw 'Post not found';
      }

      if (existingPost.createdBy != user.uid) {
        throw 'You can only update your own posts';
      }

      // Update with new timestamp
      final updatedPost = post.copyWith(updatedAt: DateTime.now());

      await _postsCollection.doc(postId).update(updatedPost.toFirestore());
    } catch (e) {
      throw 'Failed to update post: ${e.toString()}';
    }
  }

  /// DELETE: Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to delete posts';
      }

      // Get the existing post to verify ownership
      final existingPost = await getPost(postId);
      if (existingPost == null) {
        throw 'Post not found';
      }

      if (existingPost.createdBy != user.uid) {
        throw 'You can only delete your own posts';
      }

      await _postsCollection.doc(postId).delete();
    } catch (e) {
      throw 'Failed to delete post: ${e.toString()}';
    }
  }

  /// Check if user can edit/delete a post
  bool canUserModifyPost(PostModel post) {
    final user = _authService.currentUser;
    if (user == null) return false;
    return post.createdBy == user.uid;
  }

  // ========== LIKES ==========

  /// Collection reference for likes (subcollection of posts)
  CollectionReference _getLikesCollection(String postId) {
    return _postsCollection.doc(postId).collection('likes');
  }

  /// Check if current user has liked a post
  Future<bool> hasUserLikedPost(String postId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final likeDoc = await _getLikesCollection(postId).doc(user.uid).get();
      return likeDoc.exists;
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }

  /// Get like count for a post
  Future<int> getPostLikeCount(String postId) async {
    try {
      final snapshot = await _getLikesCollection(postId).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to like posts';
      }

      // Check if already liked
      final alreadyLiked = await hasUserLikedPost(postId);
      if (alreadyLiked) {
        return; // Already liked, do nothing
      }

      // Add like document
      await _getLikesCollection(
        postId,
      ).doc(user.uid).set({'userId': user.uid, 'createdAt': Timestamp.now()});

      // Update post like count
      final currentCount = await getPostLikeCount(postId);
      await _postsCollection.doc(postId).update({'likes': currentCount});
    } catch (e) {
      throw 'Failed to like post: ${e.toString()}';
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to unlike posts';
      }

      // Remove like document
      await _getLikesCollection(postId).doc(user.uid).delete();

      // Update post like count
      final currentCount = await getPostLikeCount(postId);
      await _postsCollection.doc(postId).update({'likes': currentCount});
    } catch (e) {
      throw 'Failed to unlike post: ${e.toString()}';
    }
  }

  /// Toggle like status (like if not liked, unlike if liked)
  Future<void> toggleLikePost(String postId) async {
    final hasLiked = await hasUserLikedPost(postId);
    if (hasLiked) {
      await unlikePost(postId);
    } else {
      await likePost(postId);
    }
  }

  // ========== COMMENTS ==========

  /// Collection reference for comments
  CollectionReference get _commentsCollection =>
      _firestore.collection('comments');

  /// CREATE: Add a comment to a post
  Future<String> createComment(CommentModel comment) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to comment';
      }

      // Ensure userId is set to current user
      final commentWithUser = comment.copyWith(
        userId: user.uid,
        createdAt: DateTime.now(),
      );

      final commentData = commentWithUser.toFirestore();
      final docRef = await _commentsCollection.add(commentData);

      // Update post comment count
      final post = await getPost(comment.postId);
      if (post != null) {
        final commentCount = await getPostCommentCount(comment.postId);
        await _postsCollection.doc(comment.postId).update({
          'comments': commentCount,
        });
      }

      return docRef.id;
    } catch (e) {
      throw 'Failed to create comment: ${e.toString()}';
    }
  }

  /// READ: Get comments for a post (real-time stream)
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get comment count for a post
  Future<int> getPostCommentCount(String postId) async {
    try {
      final snapshot = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting comment count: $e');
      return 0;
    }
  }

  /// DELETE: Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User must be logged in to delete comments';
      }

      // Get comment to verify ownership
      final commentDoc = await _commentsCollection.doc(commentId).get();
      if (!commentDoc.exists) {
        throw 'Comment not found';
      }

      final commentData = commentDoc.data() as Map<String, dynamic>;
      if (commentData['userId'] != user.uid) {
        throw 'You can only delete your own comments';
      }

      await _commentsCollection.doc(commentId).delete();

      // Update post comment count
      final commentCount = await getPostCommentCount(postId);
      await _postsCollection.doc(postId).update({'comments': commentCount});
    } catch (e) {
      throw 'Failed to delete comment: ${e.toString()}';
    }
  }

  /// Check if user can delete a comment
  bool canUserDeleteComment(CommentModel comment) {
    final user = _authService.currentUser;
    if (user == null) return false;
    return comment.userId == user.uid;
  }
}
