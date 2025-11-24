import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Event Details",
          style: TextStyle(
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
          // WELCOMEPAGE İLE AYNI ARKA PLAN
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF594ABF),
            ),
          ),

          // Blur daireler (WelcomePage'dekiyle aynı)
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
              children: const [
                _PosterArea(title: "EVENT TITLE"),
                SizedBox(height: 24),
                _PriceDateTime(),
                SizedBox(height: 24),

                _SectionTitle("About Event"),
                SizedBox(height: 8),
                _AboutEventBubble(),
                SizedBox(height: 24),

                _SectionTitle("Host"),
                SizedBox(height: 8),
                _HostSection(),
                SizedBox(height: 24),

                _SectionTitle("Location"),
                SizedBox(height: 8),
                _LocationSection(),
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
  const _SectionTitle(this.text, {super.key});

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
  const _PosterArea({required this.title, super.key});

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
            Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Text(
                  "Poster will be here",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 110,
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
  const _PriceDateTime({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                _DateTimeLabels(),
                _DateTimeValues(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeLabels extends StatelessWidget {
  const _DateTimeLabels({super.key});

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
  const _DateTimeValues({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        Text(
          "DD.MM.YYYY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "HH:MM",
          style: TextStyle(
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
  const _AboutEventBubble({super.key});

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

class _HostSection extends StatelessWidget {
  const _HostSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hosts = const [
      _HostCircle(label: "Host 1"),
      _HostCircle(label: "Host 2"),
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: GlassBubble(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...hosts.expand((h) => [h, const SizedBox(width: 32)]),
          ]..removeLast(),
        ),
      ),
    );
  }
}

class _HostCircle extends StatelessWidget {
  final String label;
  const _HostCircle({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.35),
          ),
          child: const Icon(Icons.group, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassBubble(
      child: SizedBox(
        height: 140,
        child: Center(
          child: Text(
            "Map will be here",
            style: TextStyle(
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

// WelcomePage'deki ile aynı BlurCircle widget'ı
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
