import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data_models.dart'; // EventModel

class EventDetailPage extends StatelessWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          event.title, // dynamic title
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // NAVBAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kFavMaroon,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // 0=Home,1=Search,2=Add,3=Tickets,4=Profile
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

      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF594ABF),
            ),
          ),

          // Blur circles
          Align(
            alignment: const Alignment(0.65, 0.55),
            child: _BlurCircle(
              size: 215,
              color: const Color(0xFFDD00FF),
              blurSigma: 40,
            ),
          ),
          Align(
            alignment: const Alignment(-0.1, 0.60),
            child: _BlurCircle(
              size: 215,
              color: const Color(0xFF9EFFEF),
              blurSigma: 40,
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 10,
              left: 16,
              right: 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PosterArea(
                  title: event.title,
                  imageUrl: event.imageUrl,
                ),
                const SizedBox(height: 24),

                _PriceDateTime(eventDate: event.date),
                const SizedBox(height: 24),

                const _SectionTitle("About Event"),
                const SizedBox(height: 8),
                const _AboutEventBubble(),
                const SizedBox(height: 24),

                const _SectionTitle("Host"),
                const SizedBox(height: 8),
                _HostSection(hostName: event.host),
                const SizedBox(height: 24),

                const _SectionTitle("Location"),
                const SizedBox(height: 8),
                _LocationSection(location: event.location),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// Poster area
class _PosterArea extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _PosterArea({
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 50.0;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(0),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            // Poster image from event
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Glassy gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.22),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Title over poster
            Positioned(
              bottom: 22,
              left: 16,
              right: 16,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF44F641),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Price / Date / Time
class _PriceDateTime extends StatelessWidget {
  final String eventDate;

  const _PriceDateTime({required this.eventDate});

  @override
  Widget build(BuildContext context) {
    // Expecting format: "27 September 2025 - 11:00"
    final parts = eventDate.split(' - ');
    final dateText = parts.isNotEmpty ? parts[0] : eventDate;
    final timeText = parts.length > 1 ? parts[1] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "PRICE",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "--- TL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _DateTimeLabels(),
                _DateTimeValues(
                  date: dateText,
                  time: timeText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeLabels extends StatelessWidget {
  const _DateTimeLabels();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "DATE",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "TIME",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DateTimeValues extends StatelessWidget {
  final String date;
  final String time;

  const _DateTimeValues({
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          date,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Glass bubble used by About/Host/Location
class GlassBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassBubble({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 50.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AboutEventBubble extends StatelessWidget {
  const _AboutEventBubble();

  @override
  Widget build(BuildContext context) {
    return const GlassBubble(
      child: Text(
        "Event description will be shown here.\n"
            "This text will come from the Create Event page.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Host section using event.host
class _HostSection extends StatelessWidget {
  final String hostName;

  const _HostSection({required this.hostName});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassBubble(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              hostName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Location section using event.location
class _LocationSection extends StatelessWidget {
  final String location;

  const _LocationSection({required this.location});

  @override
  Widget build(BuildContext context) {
    return GlassBubble(
      child: SizedBox(
        height: 140,
        child: Center(
          child: Text(
            location,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// BlurCircle
class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double blurSigma;

  const _BlurCircle({
    super.key,
    required this.size,
    required this.color,
    this.blurSigma = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
