// lib/screens/collection/collection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/collection.dart';
import '../../models/reading_progress.dart';
import '../../services/supabase_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../auth/login_screen.dart'; // To access CurrentUser
import '../../utils/app_router.dart'; // For navigation

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Collection> _collectionItems = [];
  List<ReadingProgress> _readingProgressItems = [];
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
    _fetchCollectionAndProgress();
  }

  Future<void> _fetchCollectionAndProgress() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      _collectionItems = await supabaseService.fetchUserCollections(_userId!);
      _readingProgressItems = await supabaseService.fetchUserReadingProgress(_userId!);
    } catch (e) {
      print('Error fetching collection and progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    } finally {
      if (mounted) { // Check mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getReadingStatusText(int bookId) {
    final progress = _readingProgressItems.firstWhere(
      (p) => p.bookId == bookId,
      orElse: () => ReadingProgress(
        id: '',
        userId: _userId!,
        bookId: bookId,
        currentPage: 0,
        status: ReadingStatus.notStarted,
      ),
    );
    return progress.status.value.capitalize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Collection',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        // Removed actions IconButton
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCollectionAndProgress,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _collectionItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your collection is empty. Add books from the home screen!',
                      style: TextStyle(fontSize: 18, color: AppColors.greyText),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _collectionItems.length,
                    itemBuilder: (context, index) {
                      final collection = _collectionItems[index];
                      final ebook = collection.ebook;

                      if (ebook == null) {
                        return const SizedBox.shrink(); // Should not happen with proper join
                      }

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
                            ).then((_) => _fetchCollectionAndProgress()); // Refresh on return
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
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
                                      ),
                                      if (ebook.author != null && ebook.author!.isNotEmpty)
                                        Text(
                                          ebook.author!,
                                          style: const TextStyle(
                                            color: AppColors.greyText,
                                            fontSize: 14,
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getReadingStatusText(ebook.ebookId) == 'Completed'
                                              ? AppColors.green.withOpacity(0.2)
                                              : AppColors.primaryBlue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          _getReadingStatusText(ebook.ebookId),
                                          style: TextStyle(
                                            color: _getReadingStatusText(ebook.ebookId) == 'Completed'
                                                ? AppColors.green
                                                : AppColors.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Optional: Add an icon or button here if needed, e.g., to remove from collection
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                                  onPressed: () async {
                                    try {
                                      await Provider.of<SupabaseService>(context, listen: false)
                                          .removeBookFromCollection(collection.id);
                                      _showSnackBar('Book removed from collection.', Colors.green);
                                      _fetchCollectionAndProgress();
                                    } catch (e) {
                                      _showSnackBar('Failed to remove: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // Assuming collection is accessed from home/profile
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}