import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:whatsup/providers/event_provider.dart';
import 'package:whatsup/services/firestore_service_base.dart';
import 'package:whatsup/models/data_models.dart';

class FakeFirestoreService implements FirestoreServiceBase {
  int createCalls = 0;
  int deleteCalls = 0;

  @override
  Stream<List<EventModel>> getEventsStream() => const Stream.empty();

  @override
  Stream<List<EventModel>> getUserEventsStream() => const Stream.empty();

  @override
  Future<String> createEvent(EventModel event) async {
    createCalls += 1;
    return 'fake-event-id';
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    deleteCalls += 1;
  }
}

void main() {
  testWidgets('UI rebuilds after createEvent (notifyListeners)', (tester) async {
    final fake = FakeFirestoreService();
    final provider = EventProvider(firestoreService: fake);

    var buildCount = 0;

    final event = EventModel(
      title: 'Test Event',
      location: 'Campus',
      date: '2026-01-10',
      time: '12:00',
      description: 'Desc',
      hosts: const ['Host'],
      createdBy: 'user-1',
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<EventProvider>(
              builder: (_, p, __) {
                buildCount++;
                return ElevatedButton(
                  key: const Key('createBtn'),
                  onPressed: () async => p.createEvent(event),
                  child: const Text('Create'),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(buildCount, 1);

    await tester.tap(find.byKey(const Key('createBtn')));
    await tester.pump();

    expect(fake.createCalls, 1);
    expect(buildCount, 2);
  });

  testWidgets('UI rebuilds after deleteEvent (notifyListeners)', (tester) async {
    final fake = FakeFirestoreService();
    final provider = EventProvider(firestoreService: fake);

    var buildCount = 0;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<EventProvider>(
              builder: (_, p, __) {
                buildCount++;
                return ElevatedButton(
                  key: const Key('deleteBtn'),
                  onPressed: () async => p.deleteEvent('evt-1'),
                  child: const Text('Delete'),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(buildCount, 1);

    await tester.tap(find.byKey(const Key('deleteBtn')));
    await tester.pump();

    expect(fake.deleteCalls, 1);
    expect(buildCount, 2);
  });
}
