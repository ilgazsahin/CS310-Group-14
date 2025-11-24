import 'package:flutter/material.dart';
import '../theme.dart';
import 'event_detail_page.dart';
import '../models/data_models.dart';

class FavoriteEventsPage extends StatelessWidget {
  const FavoriteEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using EventModel from data_models.dart
    final List<EventModel> events = [
      EventModel(
        title: 'Freshman Orientation',
        location: 'Sabancı University Performance Center',
        date: '27 September 2025 - 11:00',
        host: 'Orientation Office',
        imageUrl:
        'https://images.pexels.com/photos/3182796/pexels-photo-3182796.jpeg',
      ),
      EventModel(
        title: 'Career Talks',
        location: 'FASS - Sabancı University',
        date: '4 October 2025 - 20:00',
        host: 'IEEE Student Branch',
        imageUrl:
        'https://images.pexels.com/photos/1181555/pexels-photo-1181555.jpeg',
      ),
      EventModel(
        title: 'Tennis Tournament',
        location: 'Sabancı University - Sports Center',
        date: '10 October 2025 - 10:30',
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
        currentIndex:
        4, // change per screen: 0=Home,1=Search,2=Add,3=Tickets,4=Profile
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/search');
              break;
            case 2:
              Navigator.pushNamed(context, '/create-event');
              break;
            case 3:
              Navigator.pushNamed(context, '/tickets');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        // Navigate to detail page with the clicked event
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailPage(event: event),
          ),
        );
      },
      child: Card(
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
                            event.date, // from EventModel
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
      ),
    );
  }
}

