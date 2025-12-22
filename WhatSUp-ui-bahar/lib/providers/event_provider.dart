import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();


  Stream<List<EventModel>> get allEvents => _firestoreService.getEventsStream();
  Stream<List<EventModel>> get myEvents => _firestoreService.getUserEventsStream();

  Future<String> createEvent(EventModel event) async {
    try {
      final eventId = await _firestoreService.createEvent(event);
      notifyListeners();
      return eventId;
    } catch (e) {
      rethrow;
    }
  }


  Future<void> deleteEvent(String eventId) async { // ezgi wrote after that, elif sude did the first part
    try {
      await _firestoreService.deleteEvent(eventId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}