import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _hasTicket = false;
  bool _isCheckingTicket = true;
  bool _isCreatingTicket = false;

  @override
  void initState() {
    super.initState();
    _checkTicketStatus();
  }

  Future<void> _checkTicketStatus() async {
    if (widget.event.id != null) {
      try {
        final hasTicket = await _firestoreService.userHasTicket(widget.event.id!);
        if (mounted) {
          setState(() {
            _hasTicket = hasTicket;
            _isCheckingTicket = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCheckingTicket = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isCheckingTicket = false;
        });
      }
    }
  }

  Future<void> _handleGetTicket() async {
    setState(() => _isCreatingTicket = true);

    try {
      await _firestoreService.createTicket(widget.event);
      if (mounted) {
        setState(() {
          _hasTicket = true;
          _isCreatingTicket = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingTicket = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ticket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${widget.event.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (widget.event.id != null) {
                try {
                  await _firestoreService.deleteEvent(widget.event.id!);
                  if (context.mounted) {
                    Navigator.pop(context); // Go back to previous screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event deleted successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to delete event: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          widget.event.title, // dynamic title
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: _firestoreService.canUserModifyEvent(widget.event)
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteDialog(),
          ),
        ]
            : null,
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
          Container(decoration: const BoxDecoration(color: Color(0xFF594ABF))),

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
                _PosterArea(title: widget.event.title, imageUrl: widget.event.imageUrl ?? ''),
                const SizedBox(height: 24),

                _PriceDateTime(
                  eventDate: widget.event.date,
                  eventTime: widget.event.time,
                  ticketPrice: widget.event.ticketPrice,
                ),
                const SizedBox(height: 24),

                const _SectionTitle("About Event"),
                const SizedBox(height: 8),
                _AboutEventBubble(description: widget.event.description),
                const SizedBox(height: 24),

                const _SectionTitle("Host"),
                const SizedBox(height: 8),
                _HostSection(hosts: widget.event.hosts),
                const SizedBox(height: 24),

                const _SectionTitle("Location"),
                const SizedBox(height: 8),
                _LocationSection(location: widget.event.location),
                const SizedBox(height: 32),

                // Get Ticket Button
                if (!_isCheckingTicket)
                  _GetTicketButton(
                    hasTicket: _hasTicket,
                    isCreating: _isCreatingTicket,
                    onPressed: _hasTicket ? null : _handleGetTicket,
                  ),
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

  const _PosterArea({required this.title, required this.imageUrl});

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
            imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF594ABF),
                  child: const Center(
                    child: Icon(
                      Icons.event,
                      size: 64,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF594ABF),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
            )
                : Container(
              color: const Color(0xFF594ABF),
              child: const Center(
                child: Icon(Icons.event, size: 64, color: Colors.white54),
              ),
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
  final String eventTime;
  final String? ticketPrice;

  const _PriceDateTime({
    required this.eventDate,
    required this.eventTime,
    this.ticketPrice,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = ticketPrice != null && ticketPrice!.isNotEmpty
        ? '$ticketPrice TL'
        : 'Free';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PRICE",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
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
                _DateTimeValues(date: eventDate, time: eventTime),
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

  const _DateTimeValues({required this.date, required this.time});

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
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AboutEventBubble extends StatelessWidget {
  final String description;

  const _AboutEventBubble({required this.description});

  @override
  Widget build(BuildContext context) {
    return GlassBubble(
      child: Text(
        description.isNotEmpty
            ? description
            : 'No description provided for this event.',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Host section using event.hosts
class _HostSection extends StatelessWidget {
  final List<String> hosts;

  const _HostSection({required this.hosts});

  @override
  Widget build(BuildContext context) {
    if (hosts.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: GlassBubble(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'No host specified',
                style: TextStyle(
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: hosts.map((host) {
          return GlassBubble(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  host,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
    required this.size,
    required this.color,
    this.blurSigma = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _GetTicketButton extends StatelessWidget {
  final bool hasTicket;
  final bool isCreating;
  final VoidCallback? onPressed;

  const _GetTicketButton({
    required this.hasTicket,
    required this.isCreating,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBubble(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: hasTicket
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: Color(0xFF44F641), size: 24),
          SizedBox(width: 12),
          Text(
            'You have a ticket for this event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      )
          : SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isCreating ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF44F641),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isCreating
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number, size: 24),
              SizedBox(width: 8),
              Text(
                'Get Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
