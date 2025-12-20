import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/data_models.dart';
import 'auth_service.dart';

/// Service class to handle Firestore CRUD operations for Events
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

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
  CollectionReference get _ticketsCollection => _firestore.collection('tickets');

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
}
