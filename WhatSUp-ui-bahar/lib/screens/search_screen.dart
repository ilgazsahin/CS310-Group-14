import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';
import '../providers/event_provider.dart';
import '../utils/app_style.dart';
import '../utils/navigation_helper.dart';
import 'event_detail_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Focus düşmesin diye setState yerine bunu kullanıyoruz
  final ValueNotifier<String> _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _query.dispose();
    super.dispose();
  }

  int _score(EventModel e, List<String> tokens) {
    if (tokens.isEmpty) return 0;

    final title = (e.title ?? '').toLowerCase();
    final desc = (e.description ?? '').toLowerCase();
    final location = (e.location ?? '').toLowerCase();
    final date = (e.date ?? '').toLowerCase();
    final time = (e.time ?? '').toLowerCase();

    final hostsText = (e.hosts is List)
        ? (e.hosts as List).join(' ').toLowerCase()
        : (e.hosts?.toString().toLowerCase() ?? '');

    int score = 0;

    for (final t in tokens) {
      if (t.isEmpty) continue;

      if (title.contains(t)) score += 10;
      if (title.startsWith(t)) score += 4;

      if (hostsText.contains(t)) score += 6;
      if (location.contains(t)) score += 5;

      if (desc.contains(t)) score += 3;

      if (date.contains(t)) score += 2;
      if (time.contains(t)) score += 2;
    }

    return score;
  }

  void _openEventDetails(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
  }

  void _selectSuggestion(EventModel event) {
    final title = (event.title ?? '').trim();
    if (title.isNotEmpty) {
      _searchController.text = title;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
      _query.value = title;
    }

    _focusNode.unfocus();
    _openEventDetails(event);
  }

  void _clearSearch() {
    _searchController.clear();
    _query.value = '';
    _focusNode.requestFocus();
  }

  Widget _suggestionThumb(String? imageUrl) {
    final url = (imageUrl ?? '').trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        color: Colors.black12,
        child: url.isEmpty
            ? const Icon(Icons.image, size: 18)
            : Image.network(
          url,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Icon(Icons.image_not_supported, size: 18);
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final imageUrl = (event.imageUrl ?? '').trim();

    return InkWell(
      onTap: () => _openEventDetails(event),
      child: Container(
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.image),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up_alt_outlined),
                  const SizedBox(width: 4),
                  Text(event.date ?? ''),
                  const SizedBox(width: 20),
                  const Icon(Icons.chat_bubble_outline),
                  const SizedBox(width: 4),
                  Text(event.time ?? ''),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          event.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navBarBg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
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
            // main’de böyleyse onu koruduk:
              showCreateDialog(context);
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
      body: StreamBuilder<List<EventModel>>(
        stream: eventProvider.allEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load events: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final events = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Search bar (focus düşmesin diye setState yok)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        const Icon(Icons.search, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            focusNode: _focusNode,
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: "Search",
                              hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: (val) => _query.value = val,
                            onSubmitted: (val) => _query.value = val,
                          ),
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: _query,
                          builder: (context, q, _) {
                            if (q.isEmpty) return const SizedBox(width: 12);
                            return IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _clearSearch,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Dropdown + list only rebuild here
                ValueListenableBuilder<String>(
                  valueListenable: _query,
                  builder: (context, qRaw, _) {
                    final q = qRaw.trim().toLowerCase();
                    final tokens = q
                        .split(RegExp(r'\s+'))
                        .where((t) => t.isNotEmpty)
                        .toList();

                    final scored = events
                        .map((e) => MapEntry(e, _score(e, tokens)))
                        .where((pair) => tokens.isEmpty ? true : pair.value > 0)
                        .toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    final filtered = scored.map((p) => p.key).toList();

                    final showSuggestions = q.isNotEmpty;
                    final suggestions =
                    showSuggestions ? filtered.take(8).toList() : <EventModel>[];
                    final showNoResultsInDropdown =
                        showSuggestions && suggestions.isEmpty;

                    return Column(
                      children: [
                        if (suggestions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  for (int i = 0; i < suggestions.length; i++) ...[
                                    InkWell(
                                      onTap: () => _selectSuggestion(suggestions[i]),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        child: Row(
                                          children: [
                                            _suggestionThumb(suggestions[i].imageUrl),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    suggestions[i].title ?? 'Event',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    [
                                                      (suggestions[i].location ?? '').trim(),
                                                      (suggestions[i].date ?? '').trim(),
                                                      (suggestions[i].time ?? '').trim(),
                                                    ].where((x) => x.isNotEmpty).join(' • '),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color
                                                          ?.withOpacity(0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (i != suggestions.length - 1)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.15),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        else if (showNoResultsInDropdown)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_off, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'No results for "$q"',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        if (filtered.isEmpty && !showSuggestions)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text("No events found"),
                          )
                        else if (filtered.isEmpty && showSuggestions)
                          const SizedBox.shrink()
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _buildEventCard(context, filtered[index]);
                            },
                          ),
                      ],
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
}
