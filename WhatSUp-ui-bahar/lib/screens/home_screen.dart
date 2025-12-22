import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_style.dart';
import '../services/firestore_service.dart';
import 'event_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory =
      'All'; // Changed default to 'All' to show all events
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _currentMonth = DateTime.now();
  List<EventModel> _cachedEvents = []; // Cache events to prevent flicker
  List<EventModel> _cachedFilteredEvents =
      []; // Cache filtered events to prevent flicker

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navBarBg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: 0, // 0=Home,1=Search,2=Add,3=Tickets,4=Profile
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
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

      // BODY (SCROLLABLE)
      body: StreamBuilder<List<EventModel>>(
        stream: _firestoreService.getEventsStream(),
        builder: (context, eventsSnapshot) {
          // Update cached events when new data arrives, but keep showing cached data
          if (eventsSnapshot.hasData) {
            _cachedEvents = eventsSnapshot.data!;
          }

          // Use cached events to prevent flicker when month changes
          final allEvents = _cachedEvents;

          // Show loading state only on initial load
          if (eventsSnapshot.connectionState == ConnectionState.waiting &&
              _cachedEvents.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendarHeader([]), // Empty list while loading
                  const SizedBox(height: 20),
                  _buildCategoryTabs(),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildCalendarHeader(allEvents),
                const SizedBox(height: 20),
                _buildCategoryTabs(),
                const SizedBox(height: 10),
                // Real-time Firestore stream for filtered events
                StreamBuilder<List<EventModel>>(
                  stream: _selectedCategory == 'All'
                      ? _firestoreService.getEventsStream()
                      : _firestoreService.getEventsByCategoryStream(
                          _selectedCategory,
                        ),
                  builder: (context, snapshot) {
                    // Update cached filtered events when new data arrives
                    if (snapshot.hasData) {
                      _cachedFilteredEvents = snapshot.data!;
                    }

                    // Only show loading on initial load when there's no cached data
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        _cachedFilteredEvents.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Error loading events: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    // Use cached events to prevent flicker
                    final events = _cachedFilteredEvents;

                    if (events.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No events found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(events[index]);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Parse date string (DD/MM/YYYY) to DateTime
  DateTime? _parseEventDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Get dates that have events in the current month
  Set<int> _getEventDates(List<EventModel> events, DateTime month) {
    final eventDates = <int>{};
    for (final event in events) {
      final eventDate = _parseEventDate(event.date);
      if (eventDate != null &&
          eventDate.year == month.year &&
          eventDate.month == month.month) {
        eventDates.add(eventDate.day);
      }
    }
    return eventDates;
  }

  Widget _buildCalendarHeader(List<EventModel> allEvents) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final eventDates = _getEventDates(allEvents, _currentMonth);

    // Get first day of month and number of days
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    // Convert to 0-based where 0 = Sunday (for our calendar display)
    // Sunday = 7 in DateTime.weekday, so we convert: 7 -> 0, 1 -> 1, 2 -> 2, etc.
    final startingDayIndex = startingWeekday == 7 ? 0 : startingWeekday;

    // Calculate total cells needed (including empty cells at start)
    final totalCells = startingDayIndex + daysInMonth;
    final rowsNeeded = (totalCells / 7).ceil();

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
          // Month/Year header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                },
              ),
              Column(
                children: [
                  Text(
                    monthNames[_currentMonth.month - 1],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_currentMonth.year}",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                .map(
                  (e) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        e,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          // Calendar grid
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowsNeeded * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              // Calculate which day this cell represents
              final dayNumber = index - startingDayIndex + 1;

              // Empty cells before month starts
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final hasEvent = eventDates.contains(dayNumber);
              final isToday =
                  dayNumber == DateTime.now().day &&
                  _currentMonth.month == DateTime.now().month &&
                  _currentMonth.year == DateTime.now().year;

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: hasEvent
                      ? Border.all(color: Colors.white, width: 2)
                      : isToday
                      ? Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        )
                      : null,
                  color: isToday ? Colors.white.withOpacity(0.2) : null,
                ),
                child: Center(
                  child: Text(
                    "$dayNumber",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: hasEvent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: hasEvent ? 16 : 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    List<String> categories = ["All", "Academic", "Clubs", "Social"];
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
                  color: isSelected
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.calendarBg,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Only this function changed: card is now tappable
  Widget _buildEventCard(EventModel event) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
        );
      },
      child: Card(
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
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? Image.network(
                        event.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.event, size: 40),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.event, size: 40),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.calendarBg,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date} - ${event.time}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.calendarBg,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.host,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _FavoriteButton(
                event: event,
                firestoreService: _firestoreService,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final EventModel event;
  final FirestoreService firestoreService;

  const _FavoriteButton({required this.event, required this.firestoreService});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorited = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.event.id == null) {
      setState(() => _isChecking = false);
      return;
    }

    try {
      final isFavorited = await widget.firestoreService.isEventFavorited(
        widget.event.id!,
      );
      if (mounted) {
        setState(() {
          _isFavorited = isFavorited;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.event.id == null || _isChecking) return;

    try {
      if (_isFavorited) {
        await widget.firestoreService.removeFavoriteEvent(widget.event.id!);
        if (mounted) {
          setState(() => _isFavorited = false);
        }
      } else {
        await widget.firestoreService.addFavoriteEvent(widget.event.id!);
        if (mounted) {
          setState(() => _isFavorited = true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: GestureDetector(
        onTap: () {
          _toggleFavorite();
        },
        behavior: HitTestBehavior.opaque,
        child: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: _isFavorited ? AppColors.navBarBg : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
