import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Academic';

  final List<EventModel> _events = [
    EventModel(
      title: 'Chess Tournament',
      location: 'SuCool - Sabancı University',
      date: '2 December 2025 - 15.00',
      host: 'Mert Arıcan',
      imageUrl: 'https://picsum.photos/id/100/200/200',
    ),
    EventModel(
      title: 'Meeting With CEO',
      location: 'FASS - Sabancı University',
      date: '13 November 2025 - 17.30',
      host: 'Rana Eda Yurtsever',
      imageUrl: 'https://picsum.photos/id/200/200/200',
    ),
    EventModel(
      title: 'Campus Run',
      location: 'Sports Center',
      date: '15 November 2025 - 09.00',
      host: 'Sports Club',
      imageUrl: 'https://picsum.photos/id/300/200/200',
    ),
    EventModel(
      title: 'Midnight Study',
      location: 'IC - Information Center',
      date: '16 November 2025 - 23.00',
      host: 'Study Group',
      imageUrl: 'https://picsum.photos/id/400/200/200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navBarBg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/search');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      // GÖVDE (SCROLLABLE)
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarHeader(),

            const SizedBox(height: 20),

            _buildCategoryTabs(),

            const SizedBox(height: 10),

            ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(_events[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.calendarBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("November", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("2025", style: TextStyle(color: Colors.white, fontSize: 22)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                .map((e) => Text(e, style: const TextStyle(color: Colors.white70, fontSize: 12)))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              int day = index - 4;
              if (day < 1 || day > 30) return const SizedBox();

              bool isFavorite = (day == 7 || day == 8 || day == 25);
              bool isSelected = (day == 2);

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isFavorite || isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
                  color: isSelected ? Colors.white.withOpacity(0.2) : null,
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isFavorite ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    List<String> categories = ["Academic", "Clubs", "Social"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories.map((cat) {
        bool isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat;
            });
          },
          child: Column(
            children: [
              Text(
                cat,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.calendarBg,
                )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(event.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.calendarBg),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.location, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(event.date, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.calendarBg),
                      const SizedBox(width: 4),
                      Text(event.host, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(Icons.favorite, color: AppColors.navBarBg),
            ),
          ],
        ),
      ),
    );
  }
}