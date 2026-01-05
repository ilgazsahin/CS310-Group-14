import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';
import '../services/firestore_service_base.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreServiceBase _firestoreService;

  EventProvider({FirestoreServiceBase? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<EventModel>> get allEvents => _firestoreService.getEventsStream();
  Stream<List<EventModel>> get myEvents => _firestoreService.getUserEventsStream();

  Future<String> createEvent(EventModel event) async {
    final eventId = await _firestoreService.createEvent(event);
    notifyListeners();
    return eventId;
  }

  Future<void> deleteEvent(String eventId) async { // ezgi wrote after that, elif sude did the first part
    await _firestoreService.deleteEvent(eventId);
    notifyListeners();
    }
}