import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../utils/app_styles.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final List<Listing> _listings = [
    Listing(
      id: '1',
      title: 'Volleyball',
      location: 'Sports Center - Sabancı University',
      date: '15 November 2025 - 16.00',
      host: 'Efe Aslan',
      imageUrl: 'https://picsum.photos/id/10/200/200',
    ),
    Listing(
      id: '2',
      title: 'Backgammon Tour...',
      location: 'Köpüklü - Sabancı University',
      date: '21 November 2025 - 19.00',
      host: 'Efe Aslan',
      imageUrl: 'https://picsum.photos/id/20/200/200',
    ),
  ];

  void _removeListing(String id) {
    setState(() {
      _listings.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing removed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF900040),
        title: const Text('My Listings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          final listing = _listings[index];
          return _buildListingCard(listing);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF900040),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
  Widget _buildListingCard(Listing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                listing.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: AppTextStyles.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.edit, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF900040)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(listing.location, style: TextStyle(fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(listing.date, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Color(0xFF900040)),
                      const SizedBox(width: 4),
                      Text(listing.host, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeListing(listing.id),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

