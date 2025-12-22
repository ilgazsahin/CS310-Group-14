import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';
import '../providers/event_provider.dart';
import '../providers/post_provider.dart';
import '../utils/app_style.dart';
import 'event_detail_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Web focus problemi için: TextField rebuild olmasın
  final ValueNotifier<String> _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _query.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _query.value = '';
    _focusNode.requestFocus();
  }

  int _scoreText(String text, List<String> tokens, {int base = 0}) {
    final t = text.toLowerCase();
    int score = base;

    for (final tok in tokens) {
      if (tok.isEmpty) continue;
      if (t.contains(tok)) {
        score += 3;
        if (t.startsWith(tok)) score += 2;
      }
    }
    return score;
  }

  int _scoreEvent(EventModel e, List<String> tokens) {
    int s = 0;
    s += _scoreText(e.title ?? '', tokens, base: 4);
    s += _scoreText(e.description ?? '', tokens, base: 0);
    s += _scoreText(e.location ?? '', tokens, base: 1);
    s += _scoreText(e.date ?? '', tokens, base: 0);
    s += _scoreText(e.time ?? '', tokens, base: 0);
    // e.organizer yok -> kaldırdım
    return s;
  }

  int _scorePost(PostModel p, List<String> tokens) {
    int s = 0;
    s += _scoreText(p.title, tokens, base: 4);
    s += _scoreText(p.content, tokens, base: 0);
    s += _scoreText(p.authorName ?? '', tokens, base: 1);
    return s;
  }

  void _openEventDetails(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
  }

  void _openPostDetails(PostModel post) {
    // Sizde post detail route’u varsa direkt buradan açılır
    Navigator.pushNamed(context, '/post-detail', arguments: post);
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

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
      body: StreamBuilder<List<EventModel>>(
        stream: eventProvider.allEvents,
        builder: (context, eventSnap) {
          if (eventSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (eventSnap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load events: ${eventSnap.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final events = eventSnap.data ?? [];

          return StreamBuilder<List<PostModel>>(
            stream: postProvider.allPosts, // <-- sizde farklıysa burayı değiştir
            builder: (context, postSnap) {
              if (postSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (postSnap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to load posts: ${postSnap.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              }

              final posts = postSnap.data ?? [];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // SEARCH BAR
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
                                onChanged: (val) {
                                  _query.value = val;
                                },
                                onSubmitted: (val) {
                                  _query.value = val;
                                },
                              ),
                            ),
                            ValueListenableBuilder<String>(
                              valueListenable: _query,
                              builder: (context, q, _) {
                                if (q.trim().isEmpty) return const SizedBox(width: 12);
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

                    const SizedBox(height: 12),

                    // DROPDOWN + RESULTS
                    ValueListenableBuilder<String>(
                      valueListenable: _query,
                      builder: (context, qRaw, _) {
                        final q = qRaw.trim().toLowerCase();
                        final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

                        final scoredEvents = events
                            .map((e) => MapEntry(e, _scoreEvent(e, tokens)))
                            .where((pair) => tokens.isEmpty ? true : pair.value > 0)
                            .toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        final scoredPosts = posts
                            .map((p) => MapEntry(p, _scorePost(p, tokens)))
                            .where((pair) => tokens.isEmpty ? true : pair.value > 0)
                            .toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        final filteredEvents = scoredEvents.map((p) => p.key).toList();
                        final filteredPosts = scoredPosts.map((p) => p.key).toList();

                        final showSuggestions = q.isNotEmpty;

                        final List<_SuggestionItem> suggestions = [];
                        if (showSuggestions) {
                          for (final e in scoredEvents.take(6)) {
                            suggestions.add(_SuggestionItem.event(e.key, e.value));
                          }
                          for (final p in scoredPosts.take(6)) {
                            suggestions.add(_SuggestionItem.post(p.key, p.value));
                          }
                          suggestions.sort((a, b) => b.score.compareTo(a.score));
                        }

                        final limitedSuggestions =
                        showSuggestions ? suggestions.take(8).toList() : <_SuggestionItem>[];

                        return Column(
                          children: [
                            if (limitedSuggestions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: limitedSuggestions.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    itemBuilder: (context, idx) {
                                      final item = limitedSuggestions[idx];

                                      final title = item.isEvent
                                          ? (item.event!.title ?? 'Untitled Event')
                                          : item.post!.title;

                                      final subtitle = item.isEvent
                                          ? (item.event!.location ?? item.event!.date ?? '')
                                          : (item.post!.authorName ?? '');

                                      return ListTile(
                                        dense: true,
                                        leading: Icon(
                                          item.isEvent ? Icons.event : Icons.article,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.85),
                                        ),
                                        title: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          _focusNode.unfocus();
                                          if (item.isEvent) {
                                            _openEventDetails(item.event!);
                                          } else {
                                            _openPostDetails(item.post!);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),

                            const SizedBox(height: 14),

                            const _SectionHeader(title: 'Events'),
                            if (filteredEvents.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('No events found', style: TextStyle(color: Colors.grey)),
                              )
                            else
                              ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredEvents.length,
                                itemBuilder: (context, index) {
                                  return _buildEventCard(context, filteredEvents[index]);
                                },
                              ),

                            const SizedBox(height: 10),

                            const _SectionHeader(title: 'Posts'),
                            if (filteredPosts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('No posts found', style: TextStyle(color: Colors.grey)),
                              )
                            else
                              ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  return _buildPostCard(context, filteredPosts[index]);
                                },
                              ),

                            const SizedBox(height: 18),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
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
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.image),
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(event.date ?? ''),
                  const SizedBox(width: 18),
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 6),
                  Text(event.time ?? ''),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.event, size: 22),
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
                        const SizedBox(height: 2),
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

  Widget _buildPostCard(BuildContext context, PostModel post) {
    final firstImage = post.imageUrls.isNotEmpty ? post.imageUrls.first : null;
    final contentPreview =
    post.content.length > 120 ? '${post.content.substring(0, 120)}...' : post.content;

    return InkWell(
      onTap: () => _openPostDetails(post),
      child: Container(
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (firstImage != null)
              Image.network(
                firstImage,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey[300],
                child: const Icon(Icons.article, size: 50, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up_alt_outlined, size: 20),
                  const SizedBox(width: 4),
                  Text("${post.likes}"),
                  const SizedBox(width: 20),
                  const Icon(Icons.chat_bubble_outline, size: 20),
                  const SizedBox(width: 4),
                  Text("${post.comments}"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                          post.authorName ?? 'Unknown Author',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contentPreview,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _SuggestionItem {
  final EventModel? event;
  final PostModel? post;
  final int score;

  bool get isEvent => event != null;

  _SuggestionItem._({this.event, this.post, required this.score});

  factory _SuggestionItem.event(EventModel e, int score) =>
      _SuggestionItem._(event: e, score: score);

  factory _SuggestionItem.post(PostModel p, int score) =>
      _SuggestionItem._(post: p, score: score);
}
