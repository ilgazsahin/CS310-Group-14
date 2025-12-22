import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../theme.dart';
import '../utils/navigation_helper.dart';
import '../providers/auth_provider.dart';
import '../services/profile_photo_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;

  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'User';
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
    return 'Sabancı University';
  }

  Future<void> _pickProfilePhoto() async {
    if (_uploading) return;

    setState(() => _uploading = true);
    try {
      await ProfilePhotoService.pickResizeAndSaveToFirestore();
      if (!mounted) return;
      // StreamBuilder zaten otomatik güncelleyecek.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userEmail = user?.email ?? '';
    final displayName = _getDisplayName(userEmail);
    final department = _getDepartment(userEmail);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryPurple,
        body: const SafeArea(
          child: Center(child: Text('Not logged in', style: TextStyle(color: Colors.white))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kFavMaroon,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 4,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Avatar + user info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        Uint8List? imageBytes;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final b64 = data['photoBase64'];
                          if (b64 is String && b64.isNotEmpty) {
                            imageBytes = ProfilePhotoService.decodeBase64ToBytes(b64);
                          }
                        }

                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: (imageBytes != null) ? MemoryImage(imageBytes) : null,
                          child: (imageBytes == null)
                              ? Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          )
                              : null,
                        );
                      },
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: AppTextStyles.headerName),
                          const SizedBox(height: 5),
                          Text(department, style: AppTextStyles.headerDepartment),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
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

                // Edit profile picture (clickable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: InkWell(
                      onTap: _uploading ? null : _pickProfilePhoto,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _uploading ? 'Uploading...' : 'Edit your profile picture',
                            style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          if (_uploading)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                _buildProfileButton(context, 'Favorite Events', () {
                  Navigator.pushNamed(context, '/favorites');
                }),
                const SizedBox(height: 15),

                _buildProfileButton(context, 'My Listings', () {
                  Navigator.pushNamed(context, '/my_listings');
                }),
                const SizedBox(height: 15),

                _buildProfileButton(context, 'My Posts', () {
                  Navigator.pushNamed(context, '/my-posts');
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
                        final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.signOut();

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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'LOG OUT []->',
                        style: TextStyle(
                          color: kFavMaroon,
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

  Widget _buildProfileButton(
      BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.accentGreen),
          ],
        ),
      ),
    );
  }
}
