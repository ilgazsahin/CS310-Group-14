import '../models/data_models.dart';

abstract class FirestoreServiceBase {
  Stream<List<EventModel>> getEventsStream();
  Stream<List<EventModel>> getUserEventsStream();

  /// Returns the created Firestore document ID
  Future<String> createEvent(EventModel event);

  Future<void> deleteEvent(String eventId);
}
