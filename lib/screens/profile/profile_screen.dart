// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user.dart';
import '../../models/reading_progress.dart';
import '../../services/supabase_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/app_router.dart';
import '../auth/login_screen.dart'; // To access CurrentUser
import '../auth/welcome_screen.dart'; // For logout navigation
import 'dart:math';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  List<ReadingProgress> _readingProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<CurrentUser>(context, listen: false).user;
    if (_currentUser == null) {
      Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      return;
    }
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      _readingProgress = await supabaseService.fetchUserReadingProgress(_currentUser!.id);
    } catch (e) {
      print('Error fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    } finally {
      if (mounted) { // Check mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int get _totalBooksRead {
    return _readingProgress.where((rp) => rp.status == ReadingStatus.completed).length;
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Clear user state in the provider
      Provider.of<CurrentUser>(context, listen: false).setUser(null);
      // Navigate to the welcome screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    } finally {
      if (mounted) { // Check mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        // Removed leading IconButton
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: _logout,
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfileData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Info Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.lightBlue,
                              child: Text(
                                _currentUser?.name?.substring(0, 1).toUpperCase() ?? '?',
                                style: const TextStyle(fontSize: 30, color: AppColors.darkBlue),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${_currentUser?.name ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Total reading: $_totalBooksRead',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // My Collection Section (from profile view)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Collection',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryBlue),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.collectionRoute)
                                .then((_) => _fetchProfileData()); // Refresh on return
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _readingProgress.isEmpty
                        ? const Text('No reading progress recorded.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _readingProgress.length,
                            itemBuilder: (context, index) {
                              final progress = _readingProgress[index];
                              final ebook = progress.ebook;

                              if (ebook == null) {
                                return const SizedBox.shrink(); // Should not happen with proper join
                              }

                              // Calculate days ago (simplified, assuming created_at for user)
                              // For actual progress, you'd need a 'last_updated' timestamp on reading_progress
                              final daysAgo = DateTime.now().difference(_currentUser!.createdAt ?? DateTime.now()).inDays;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.bookDetailRoute,
                                      arguments: ebook,
                                    ).then((_) => _fetchProfileData()); // Refresh on return
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Placeholder for book cover image
                                        Container(
                                          width: 60,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGrey,
                                            borderRadius: BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                'https://picsum.photos/seed/${Random().nextInt(1000)}/200/300',
                                              ),
                                              fit: BoxFit.cover,
                                              onError: (exception, stackTrace) {
                                                print('Error loading image: $exception');
                                              },
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: ebook.title.isEmpty
                                              ? const Icon(Icons.book, size: 30, color: AppColors.greyText)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ebook.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '$daysAgo day ago', // Simplified: days since user created, not book progress
                                                style: const TextStyle(
                                                  color: AppColors.greyText,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                '${progress.currentPage}/${ebook.pageNumber ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
