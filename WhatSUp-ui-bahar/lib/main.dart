import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', // tüm yazılar Poppins
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

// -------------------------------------------------------------
//                       WELCOME PAGE
// -------------------------------------------------------------

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Ana gradient arka plan
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6A5AE0),
                  Color(0xFF8A62D5),
                  Color(0xFFCE67C4),
                  Color(0xFFF58CAF),
                ],
              ),
            ),
          ),

          // 2) Blur daireler (Figma’daki ellipsler)
          // Sağdaki pembe daire
          const Align(
            alignment: Alignment(0.65, 0.55),
            child: _BlurCircle(
              size: 215,
              color: Color(0xFFDD00FF), // pembe
              blurSigma: 40,
            ),
          ),

          // Soldaki mavi/yeşil daire
          const Align(
            alignment: Alignment(-0.1, 0.60),
            child: _BlurCircle(
              size: 215,
              color: Color(0xFF9EFFEF), // mavi-yeşil
              blurSigma: 40,
            ),
          ),

          // 3) Asıl içerik (EventDrop + butonlar)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // EventDrop kartı
                    Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "EventDrop",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 180,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "'s up?",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Decline",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Accept",
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // LOGIN
                    _GradientButton(
                      text: 'LOGIN',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // SIGN UP
                    _GradientButton(
                      text: 'SIGN UP',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Dev için preview butonu
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventDetailPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Preview Event Detail (dev only)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Blur daire widget'ı
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

// Login / Sign Up gradient butonu
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 306, // Figma: W 306
      height: 72, // Figma: H 72
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF94C6FF), // mavi
            Color(0xFFF458C4), // pembe
          ],
        ),
        borderRadius: BorderRadius.circular(50), // Figma radius 50
        border: Border.all(
          color: Colors.white.withOpacity(0.22), // stroke
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
//                       EVENT DETAIL PAGE
// -------------------------------------------------------------

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
      bottomNavigationBar: const _BottomNavBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient arkaplan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6A5AE0),
                  Color(0xFFCE67C4),
                  Color(0xFFF58CAF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Tüm arka plana blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.0),
            ),
          ),
          // İçerik
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 10, // poster daha yukarı
              left: 16,
              right: 16,
              bottom: 100, // bottom bar için boşluk
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

// Alt navigasyon bar
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB6316F),
            Color(0xFF8A1A80),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _BottomNavItem(icon: Icons.home, label: "Home"),
            _BottomNavItem(icon: Icons.search, label: "Search"),
            _BottomNavItem(icon: Icons.add_circle_outline, label: "Add"),
            _BottomNavItem(icon: Icons.article_outlined, label: "News"),
            _BottomNavItem(icon: Icons.celebration, label: "Party"),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomNavItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
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

// -------------------------------------------------------------
// POSTER (üst köşeler düz, alt köşeler radius 50 + yumuşak blur)
// -------------------------------------------------------------

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
            // Poster placeholder
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

            // Alt blur + yumuşak gradient overlay
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

            // Başlık (yeşil, kalın)
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

// -------------------------------------------------------------
// PRICE / DATE / TIME  (price buble içinde DEĞİL)
// -------------------------------------------------------------

class _PriceDateTime extends StatelessWidget {
  const _PriceDateTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          // PRICE – sadece metin
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

          // DATE + TIME sağ tarafta: solda label, sağda value
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

// -------------------------------------------------------------
// GLASS BUBBLE (About / Host / Location)
// -------------------------------------------------------------

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

// -------------------------------------------------------------
// ABOUT EVENT BUBBLE
// -------------------------------------------------------------

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

// -------------------------------------------------------------
// HOST BUBBLE
// -------------------------------------------------------------

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
            ...hosts.expand(
                  (h) => [h, const SizedBox(width: 32)],
            ),
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

// -------------------------------------------------------------
// LOCATION BUBBLE
// -------------------------------------------------------------

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

// -------------------------------------------------------------
// BASİT LOGIN & SIGNUP PLACEHOLDER SAYFALARI
// -------------------------------------------------------------

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: const Center(
        child: Text("Login Page UI will be here"),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: const Center(
        child: Text("Sign Up Page UI will be here"),
      ),
    );
  }
}
