import 'package:flutter/material.dart';
import '../theme.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  // Bottom nav index: 0 = Home, 1 = Search, 2 = Add, 3 = Tickets, 4 = Profile
  int _selectedIndex = 3;

  late List<Ticket> _tickets;

  @override
  void initState() {
    super.initState();
    // Copy initial tickets so we can mutate this list locally
    _tickets = List<Ticket>.from(initialTickets);
  }

  void _onBottomNavTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/create-event');
        break;
      case 3:
      // Already on tickets
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _toggleFavorite(int index) {
    setState(() {
      final ticket = _tickets[index];
      _tickets[index] =
          ticket.copyWith(isFavorite: !ticket.isFavorite); // immutable update
    });
  }

  // if we later want a "Cancel ticket" option, we can use this
  void _removeTicket(int index) {
    setState(() {
      _tickets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: kCreatePurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tickets',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _tickets.isEmpty
          ? const Center(
        child: Text(
          "You don't have any tickets yet.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return _buildTicketCard(ticket, index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: kFavMaroon,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: event image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: Image.network(
                  ticket.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right: details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + favorite button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          ticket.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          ticket.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: ticket.isFavorite ? kFavMaroon : null,
                        ),
                        onPressed: () => _toggleFavorite(index),
                        tooltip: ticket.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ticket.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Date & time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ticket.dateTime,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Organizer
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ticket.organizer,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category pill
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ticket.categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ticket.categoryLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ticket.categoryColor,
                        ),
                      ),
                    ),
                  ),
                  // For the cancel ticket button
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        // Optional: confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel ticket'),
                            content: const Text(
                                'Are you sure you want to remove this ticket?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // close dialog
                                  _removeTicket(index);   // actually remove
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Cancel ticket'),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple model for tickets on this page.
class Ticket {
  final String title;
  final String location;
  final String dateTime;
  final String organizer;
  final TicketCategory category;
  final String imageUrl;
  final bool isFavorite; // new field

  const Ticket({
    required this.title,
    required this.location,
    required this.dateTime,
    required this.organizer,
    required this.category,
    required this.imageUrl,
    this.isFavorite = false, // default so old sample data still compiles
  });

  Ticket copyWith({
    String? title,
    String? location,
    String? dateTime,
    String? organizer,
    TicketCategory? category,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Ticket(
      title: title ?? this.title,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get categoryLabel {
    switch (category) {
      case TicketCategory.academic:
        return 'academic';
      case TicketCategory.clubs:
        return 'clubs';
    }
  }

  Color get categoryColor {
    switch (category) {
      case TicketCategory.academic:
        return kCreatePurple;
      case TicketCategory.clubs:
        return Colors.green;
    }
  }
}

enum TicketCategory { academic, clubs }

// Sample tickets adapted to the new model; they all start with isFavorite = false.
// Sample models use placeholder images which may not be relevant to the event for now. This will fix when /images folder is implemented.
const List<Ticket> initialTickets = [
  Ticket(
    title: 'Freshman Orientation',
    location: 'Sabancı University Performance Center',
    dateTime: '27 September 2025 · 14:00',
    organizer: 'Student Resources',
    category: TicketCategory.academic,
    imageUrl:
    'https://images.pexels.com/photos/1181400/pexels-photo-1181400.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  Ticket(
    title: 'Career Talks',
    location: 'FASS G052',
    dateTime: '4 October 2025 · 15:00',
    organizer: 'IES',
    category: TicketCategory.academic,
    imageUrl:
    'https://images.pexels.com/photos/1181567/pexels-photo-1181567.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  Ticket(
    title: 'Basketball Tournament',
    location: 'Sabancı University Sports Center',
    dateTime: '10 October 2025 · 16:30',
    organizer: 'Sports Club',
    category: TicketCategory.clubs,
    imageUrl:
    'https://www.secsports.com/imgproxy/zIXmm0sfOOiSX42VjM_P7d0A64oGOkV0uBY1G-vFkrM/rs:fit:1980:0:0:g:ce/aHR0cHM6Ly9zdG9yYWdlLmdvb2dsZWFwaXMuY29tL3NlY3Nwb3J0cy1wcm9kL3VwbG9hZC8yMDI0LzAxLzMxLzQ5MTYyMTUxLWI0ZjQtNDhkNC1hMGJlLWU4YjhjNDNhMWNmNi5qcGc.jpg',
  ),
  Ticket(
    title: 'Halloween Party',
    location: 'Sabancı University Lake',
    dateTime: '31 October 2025 · 22:00',
    organizer: 'Student Council',
    category: TicketCategory.clubs,
    imageUrl:
    'https://images.pexels.com/photos/6194201/pexels-photo-6194201.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
];
