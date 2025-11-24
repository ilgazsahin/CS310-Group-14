import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kFavMaroon,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 4, // 0=Home,1=Search,2=Add,3=Tickets,4=Profile
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Efe Aslan', style: AppTextStyles.headerName),
                          SizedBox(height: 5),
                          Text(
                            'Faculty of Arts and\nSocial Sciences',
                            style: AppTextStyles.headerDepartment,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      'Edit your profile picture',
                      style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                _buildProfileButton(context, 'Edit My Profile', () {}),
                const SizedBox(height: 15),

                _buildProfileButton(context, 'Favorite Events', () {
                  Navigator.pushNamed(context, '/favorites');
                }),
                const SizedBox(height: 15),

                _buildProfileButton(context, 'My Listings', () {
                  Navigator.pushNamed(context, '/my_listings');
                }),
                const SizedBox(height: 15),

                _buildProfileButton(context, 'Settings', () {}),
                const SizedBox(height: 15),



                InkWell(
                  onTap: () {
                    // tüm sayfa geçmişini silip WelcomePage'e dön
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',              // main.dart'taki WelcomePage route'u
                          (route) => false, // önceki tüm sayfaları sil
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'LOG OUT []->',
                        style: TextStyle(
                          color: Color(0xFF900040),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: AppTextStyles.buttonText),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.accentGreen),
          ],
        ),
      ),
    );
  }
}