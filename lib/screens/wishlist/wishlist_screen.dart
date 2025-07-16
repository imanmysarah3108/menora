// lib/screens/wishlist/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/wishlist.dart';
import '../../services/supabase_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../auth/login_screen.dart'; // To access CurrentUser
import '../../utils/app_router.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Wishlist> _wishlistItems = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<CurrentUser>(context, listen: false).user?.id;
    if (_userId == null) {
      Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      return;
    }
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      _wishlistItems = await supabaseService.fetchUserWishlist(_userId!);
    } catch (e) {
      print('Error fetching wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading wishlist: ${e.toString()}')),
      );
    } finally {
      if (mounted) { // Check mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeWishlistItem(String wishlistId) async {
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      await supabaseService.removeWishlistItem(wishlistId);
      _showSnackBar('Item removed from wishlist.', Colors.green);
      _fetchWishlist(); // Refresh the list
    } catch (e) {
      _showSnackBar('Failed to remove item: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'My Wishlist',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column( // Use Column to stack the list and the ad banner
        children: [
          Expanded( // Expanded to allow the ListView to take available space
            child: RefreshIndicator(
              onRefresh: _fetchWishlist,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _wishlistItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Your wishlist is empty.',
                            style: TextStyle(fontSize: 18, color: AppColors.greyText),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _wishlistItems.length,
                          itemBuilder: (context, index) {
                            final item = _wishlistItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.bookTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (item.bookAuthor != null && item.bookAuthor!.isNotEmpty)
                                            Text(
                                              item.bookAuthor!,
                                              style: const TextStyle(
                                                color: AppColors.greyText,
                                                fontSize: 14,
                                              ),
                                            ),
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item.status == BookStatus.available
                                                  ? AppColors.green.withOpacity(0.2)
                                                  : AppColors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              item.status.value.capitalize(),
                                              style: TextStyle(
                                                color: item.status == BookStatus.available
                                                    ? AppColors.green
                                                    : AppColors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: AppColors.red),
                                      onPressed: () => _removeWishlistItem(item.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          // Mockup Banner Ad Area
          Container(
            height: 70.0, // Standard banner ad height (e.g., 50 or 100)
            width: double.infinity, // Take full width
            color: AppColors.lightGrey, // A neutral background for the ad
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 8.0), // Some space from the list items
            child: const Text(
              'Mockup Banner Ad',
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
