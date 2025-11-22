import 'package:flutter/material.dart';
import '../theme.dart';
import 'event_detail_page.dart';

class FavoriteEventsPage extends StatelessWidget {
  const FavoriteEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      EventData(
        title: 'Freshman Orientation',
        location: 'Sabancı University Performance Center',
        dateTime: '27 September 2025 - 11:00',
        host: 'Orientation Office',
        imageUrl:
        'https://images.pexels.com/photos/3182796/pexels-photo-3182796.jpeg',
      ),
      EventData(
        title: 'Career Talks',
        location: 'FASS - Sabancı University',
        dateTime: '4 October 2025 - 20:00',
        host: 'IEEE Student Branch',
        imageUrl:
        'https://images.pexels.com/photos/1181555/pexels-photo-1181555.jpeg',
      ),
      EventData(
        title: 'Tennis Tournament',
        location: 'Sabancı University - Sports Center',
        dateTime: '10 October 2025 - 10:30',
        host: 'Murat Yılmaz',
        imageUrl:
        'https://images.pexels.com/photos/114296/pexels-photo-114296.jpeg',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kFavMaroon,
        foregroundColor: Colors.white,
        title: const Text('Favorite Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventCard(event: events[index]),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kFavMaroon,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Add tab selected or whatever you use here
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/create-event');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),

    );
  }
}

class EventData {
  final String title;
  final String location;
  final String dateTime;
  final String host;
  final String imageUrl;

  EventData({
    required this.title,
    required this.location,
    required this.dateTime,
    required this.host,
    required this.imageUrl,
  });
}

class EventCard extends StatelessWidget {
  final EventData event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: kFavMaroon),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.dateTime,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.host,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite, color: kFavMaroon),
            ),
          ],
        ),
      ),
    );
  }
}
