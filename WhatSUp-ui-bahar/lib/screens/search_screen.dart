import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_style.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static final List<PostModel> _posts = [
    PostModel(
      username: "Movie Night!",
      caption: "Come join us for Interstellar!",
      imageUrl: "https://img.freepik.com/free-photo/popcorn-juice-movie-night_23-2148470131.jpg?semt=ais_hybrid&w=740&q=80",
      likes: 32,
      comments: 14,
    ),
    PostModel(
      username: "Picnic with everybody!",
      caption: "Sunny day at the campus lake.",
      imageUrl: "https://images.stockcake.com/public/7/f/a/7fab551b-02f6-40d2-94c2-06138b16c4c0_large/idyllic-lakeside-picnic-stockcake.jpg",
      likes: 27,
      comments: 5,
    ),
    PostModel(
      username: "Tech Talk",
      caption: "Learning Flutter is fun.",
      imageUrl: "https://media.istockphoto.com/id/2174406748/photo/woman-is-presenting-a-phone.jpg?s=612x612&w=0&k=20&c=ccnWslGUMEonLey8OWp3RDNFESYUg_ST0WuFQQSBwQE=",
      likes: 102,
      comments: 45,
    ),
    PostModel(
      username: "Music Fest",
      caption: "Live music tonight!",
      imageUrl: "https://www.udiscovermusic.com/wp-content/uploads/2017/06/Coachella-GettyImages-673625850-1000x600.jpg",
      likes: 150,
      comments: 60,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navBarBg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1, // 0=Home,1=Search,2=Add,3=Tickets,4=Profile
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: 'Tickets'),
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
                return _buildPostCard(context, _posts[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Container(
      color: Theme.of(context).cardColor,
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