import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'widgets/auth_wrapper.dart';
import 'providers/auth_provider.dart';
import 'screens/event_detail_page.dart';
import 'screens/create_event_page.dart';
import 'screens/favorite_events_page.dart';
import 'screens/profile_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/tickets_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/settings_page.dart';

import 'models/data_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Event App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kCreatePurple),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        // First screen of the app - AuthWrapper handles routing based on auth state
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/create-event': (context) => const CreateEventPage(),
          '/favorites': (context) => const FavoriteEventsPage(),
          '/event-detail': (context) {
            final event =
                ModalRoute.of(context)!.settings.arguments as EventModel;
            return EventDetailPage(event: event);
          },
          '/profile': (context) => const ProfileScreen(),
          '/my_listings': (context) => const MyListingsScreen(),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/tickets': (context) => const TicketsPage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
