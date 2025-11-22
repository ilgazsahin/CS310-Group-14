import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';
import 'screens/welcome_page.dart';
import 'screens/event_detail_page.dart';
import 'screens/create_event_page.dart';
import 'screens/favorite_events_page.dart';
import 'screens/profile_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kCreatePurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // First screen of the app
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(), // simple internal menu
        '/create-event': (context) => const CreateEventPage(),
        '/favorites': (context) => const FavoriteEventsPage(),
        '/event-detail': (context) => const EventDetailPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event App'),
        backgroundColor: kCreatePurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kCreatePurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, '/create-event'),
              child: const Text('Create Event'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kFavMaroon,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
              child: const Text('Favorite Events'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/event-detail'),
              child: const Text('Event Detail (dev)'),
            ),
          ],
        ),
      ),
    );
  }
}
