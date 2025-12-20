import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'User';
    // Extract name from email (e.g., "john.doe@sabanciuniv.edu" -> "John Doe")
    final emailPrefix = email.split('@').first;
    if (emailPrefix.isEmpty) return 'User';
    
    final parts = emailPrefix.split('.');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      final firstName = parts[0].length > 1 
          ? '${parts[0][0].toUpperCase()}${parts[0].substring(1)}'
          : parts[0].toUpperCase();
      final lastName = parts[1].length > 1
          ? '${parts[1][0].toUpperCase()}${parts[1].substring(1)}'
          : parts[1].toUpperCase();
      return '$firstName $lastName';
    }
    return emailPrefix.length > 1
        ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1)
        : emailPrefix.toUpperCase();
  }

  String _getDepartment(String? email) {
    // You can customize this based on your needs
    // For now, return a default or extract from email if there's a pattern
    return 'Sabancı University';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userEmail = user?.email ?? '';
    final displayName = _getDisplayName(userEmail);
    final department = _getDepartment(userEmail);
    
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
                      backgroundColor: Colors.white,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: AppTextStyles.headerName),
                          const SizedBox(height: 5),
                          Text(
                            department,
                            style: AppTextStyles.headerDepartment,
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
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

                _buildProfileButton(context, 'Settings', () {
                  Navigator.pushNamed(context, '/settings');
                }),
                const SizedBox(height: 15),



                InkWell(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF900040),
                              ),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.signOut();
                        // Navigation will be handled by AuthWrapper
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to sign out: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
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