import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:whatsup/providers/event_provider.dart';
import 'package:whatsup/services/firestore_service_base.dart';
import 'package:whatsup/models/data_models.dart';

class FakeFirestoreService implements FirestoreServiceBase {
  int createCalls = 0;
  int deleteCalls = 0;

  EventModel? lastCreated;
  String? lastDeletedId;

  final Stream<List<EventModel>> _eventsStream;
  final Stream<List<EventModel>> _userEventsStream;

  FakeFirestoreService({
    Stream<List<EventModel>>? eventsStream,
    Stream<List<EventModel>>? userEventsStream,
  })  : _eventsStream = eventsStream ?? const Stream.empty(),
        _userEventsStream = userEventsStream ?? const Stream.empty();

  @override
  Stream<List<EventModel>> getEventsStream() => _eventsStream;

  @override
  Stream<List<EventModel>> getUserEventsStream() => _userEventsStream;

  @override
  Future<String> createEvent(EventModel event) async {
    createCalls += 1;
    lastCreated = event;
    return 'fake-event-id';
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    deleteCalls += 1;
    lastDeletedId = eventId;
  }
}

class FailingCreateFirestoreService implements FirestoreServiceBase {
  @override
  Stream<List<EventModel>> getEventsStream() => const Stream.empty();

  @override
  Stream<List<EventModel>> getUserEventsStream() => const Stream.empty();

  @override
  Future<String> createEvent(EventModel event) async {
    throw Exception('create failed');
  }

  @override
  Future<void> deleteEvent(String eventId) async {}
}

void main() {
  test('createEvent delegates to service, notifies once, and returns eventId', () async {
    final fake = FakeFirestoreService();
    final provider = EventProvider(firestoreService: fake);

    var notifyCount = 0;
    provider.addListener(() => notifyCount++);

    final event = EventModel(
      title: 'Teoman Concert',
      location: 'Kucukciftlik Park',
      date: '2026-01-10',
      time: '21:00',
      description: 'Live music show of the famous Turkish rockstar Teoman',
      ticketPrice: '1000',
      hosts: ['Host A'],
      category: 'Music',
      imageUrl: null,
      createdBy: 'Bayhan',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: null,
    );

    final id = await provider.createEvent(event);

    expect(id, 'fake-event-id');
    expect(fake.createCalls, 1);
    expect(fake.lastCreated, isNotNull);
    expect(fake.lastCreated!.title, 'Teoman Concert');
    expect(notifyCount, 1);
  });

  test('deleteEvent delegates to service and notifies listeners once', () async {
    final fake = FakeFirestoreService();
    final provider = EventProvider(firestoreService: fake);

    var notifyCount = 0;
    provider.addListener(() => notifyCount++);

    await provider.deleteEvent('evt-123');

    expect(fake.deleteCalls, 1);
    expect(fake.lastDeletedId, 'evt-123');
    expect(notifyCount, 1);
  });

  test('allEvents returns the service stream and emits values', () async {
    final controller = StreamController<List<EventModel>>();
    final fake = FakeFirestoreService(eventsStream: controller.stream);
    final provider = EventProvider(firestoreService: fake);

    final received = <List<EventModel>>[];
    final sub = provider.allEvents.listen(received.add);

    controller.add(<EventModel>[]);
    await Future<void>.delayed(Duration.zero);

    expect(received.length, 1);
    expect(received.first, isEmpty);

    await sub.cancel();
    await controller.close();
  });

  test('createEvent propagates exception and does not notify listeners on failure', () async {
    final failing = FailingCreateFirestoreService();
    final provider = EventProvider(firestoreService: failing);

    var notifyCount = 0;
    provider.addListener(() => notifyCount++);

    final event = EventModel(
      title: 'Bad Event',
      location: 'Nowhere',
      date: '2026-01-10',
      time: '00:00',
      description: 'Should fail',
      hosts: const ['Host'],
      createdBy: 'user-1',
      createdAt: DateTime(2026, 1, 1),
    );

    await expectLater(
          () => provider.createEvent(event),
      throwsA(isA<Exception>()),
    );

    expect(notifyCount, 0);
  });
}
