import 'package:flutter/material.dart';
import '../theme.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kFavMaroon,
        foregroundColor: Colors.white,
        title: const Text('My Tickets'),
      ),
      body: const Center(
        child: Text(
          'Tickets page coming soon',
          style: TextStyle(fontSize: 16),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kFavMaroon,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // 0=Home,1=Search,2=Add,3=Tickets,4=Profile
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
