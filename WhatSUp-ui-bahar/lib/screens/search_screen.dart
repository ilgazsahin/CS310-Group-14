import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_style.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static final List<PostModel> _posts = [
    PostModel(
      username: "Movie Night!",
      caption: "Come join us for Interstellar!",
      imageUrl: "https://picsum.photos/id/400/400/250",
      likes: 32,
      comments: 14,
    ),
    PostModel(
      username: "Picnic with everybody!",
      caption: "Sunny day at the campus lake.",
      imageUrl: "https://picsum.photos/id/500/400/250",
      likes: 27,
      comments: 5,
    ),
    PostModel(
      username: "Tech Talk",
      caption: "Learning Flutter is fun.",
      imageUrl: "https://picsum.photos/id/600/400/250",
      likes: 102,
      comments: 45,
    ),
    PostModel(
      username: "Music Fest",
      caption: "Live music tonight!",
      imageUrl: "https://picsum.photos/id/700/400/250",
      likes: 150,
      comments: 60,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navBarBg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 15),
                    Icon(Icons.search, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Text("Search", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_posts[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            post.imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.thumb_up_alt_outlined),
                const SizedBox(width: 4),
                Text("${post.likes}"),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline),
                const SizedBox(width: 4),
                Text("${post.comments}"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.account_circle, size: 28),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.caption, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}