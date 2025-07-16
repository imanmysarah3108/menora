// lib/screens/home/book_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/book.dart';
import '../../models/review.dart';
import '../../models/reading_progress.dart';
import '../../services/supabase_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/rating_stars.dart';
import '../../utils/app_router.dart';
import '../auth/login_screen.dart'; // To access CurrentUser
import 'dart:math';

class BookDetailScreen extends StatefulWidget {
  final Ebook ebook;

  const BookDetailScreen({super.key, required this.ebook});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  String? _userId;
  ReadingProgress? _userReadingProgress;
  bool _isInCollection = false;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<CurrentUser>(context, listen: false).user?.id;
    if (_userId == null) {
      Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      return;
    }
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoadingReviews = true;
    });
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      _reviews = await supabaseService.fetchBookReviews(widget.ebook.ebookId);

      // Check if book is in user's collection
      final collections = await supabaseService.fetchUserCollections(_userId!);
      _isInCollection = collections.any((c) => c.bookId == widget.ebook.ebookId);

      // Fetch user's reading progress for this book
      final userProgress = await supabaseService.fetchUserReadingProgress(_userId!);
      _userReadingProgress = userProgress.firstWhere(
        (rp) => rp.bookId == widget.ebook.ebookId,
        orElse: () => ReadingProgress(
          id: '', // Placeholder
          userId: _userId!,
          bookId: widget.ebook.ebookId,
          currentPage: 0,
          status: ReadingStatus.notStarted,
        ),
      );
    } catch (e) {
      print('Error fetching book details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: ${e.toString()}')),
      );
    } finally {
      if (mounted) { // Check mounted before calling setState
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _toggleCollection() async {
    if (_userId == null) return;
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    try {
      if (_isInCollection) {
        // Find and remove from collection
        final collections = await supabaseService.fetchUserCollections(_userId!);
        final collectionItem = collections.firstWhere((c) => c.bookId == widget.ebook.ebookId);
        await supabaseService.removeBookFromCollection(collectionItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book removed from collection.')),
        );
      } else {
        // Add to collection
        await supabaseService.addBookToCollection(_userId!, widget.ebook.ebookId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added to collection!')),
        );
      }
      if (mounted) { // Check mounted before calling setState
        setState(() {
          _isInCollection = !_isInCollection;
        });
      }
    } catch (e) {
      if (mounted) { // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update collection: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
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
          'Book Detail',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBookDetails,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(10.0),
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
                  child: widget.ebook.title.isEmpty
                      ? const Icon(Icons.book, size: 80, color: AppColors.greyText)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.ebook.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              if (widget.ebook.author != null && widget.ebook.author!.isNotEmpty)
                Text(
                  'by ${widget.ebook.author!}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.greyText,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                widget.ebook.publisher != null && widget.ebook.publisher!.isNotEmpty
                    ? 'Publisher: ${widget.ebook.publisher!}'
                    : 'Publisher: N/A',
                style: const TextStyle(fontSize: 14, color: AppColors.greyText),
              ),
              Text(
                widget.ebook.yearPublished != null
                    ? 'Year: ${widget.ebook.yearPublished!}'
                    : 'Year: N/A',
                style: const TextStyle(fontSize: 14, color: AppColors.greyText),
              ),
              Text(
                widget.ebook.pageNumber != null
                    ? 'Pages: ${widget.ebook.pageNumber!}'
                    : 'Pages: N/A',
                style: const TextStyle(fontSize: 14, color: AppColors.greyText),
              ),
              Text(
                widget.ebook.genre != null && widget.ebook.genre!.isNotEmpty
                    ? 'Genre: ${widget.ebook.genre!}'
                    : 'Genre: N/A',
                style: const TextStyle(fontSize: 14, color: AppColors.greyText),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dr. Iman Syahirah seorang wanita berdikari dan berkeyakinan tinggi; selalu tahu apa yang dimahukan dalam hidupnya. Namun, tiada siapa tahu, doktor yang kelihatan tegas ini menyimpan kisah silam yang dijaga rapi. Dia sendiri tidak ingin mengenang lagi. Walau bagaimanapun, pertemuan dengan Aleph telah menimbulkan kembali gelodak perasaan lama yang disangka telah terhapus sepenuhnya. Lamunan Faris secara tiba-tiba meniembusi memori Iman jalan keluar daripada kemelut tersebut.',
                style: const TextStyle(fontSize: 15, color: AppColors.greyText),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isInCollection ? Icons.bookmark : Icons.bookmark_border,
                          size: 30,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: _toggleCollection,
                      ),
                      Text(
                        _isInCollection ? 'Saved' : 'Save',
                        style: const TextStyle(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.star_border, size: 30, color: AppColors.primaryBlue),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.reviewRoute,
                            arguments: widget.ebook,
                          ).then((_) => _fetchBookDetails()); // Refresh reviews after returning
                        },
                      ),
                      const Text(
                        'Review',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Reading Progress Section - Moved above User Review
              const Text(
                'Reading Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 10),
              _userReadingProgress != null
                  ? Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Page: ${_userReadingProgress!.currentPage}/${widget.ebook.pageNumber ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Status: ${_userReadingProgress!.status.value.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _userReadingProgress!.status == ReadingStatus.completed
                                    ? AppColors.green
                                    : AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showUpdateProgressDialog(
                                        _userReadingProgress!.currentPage, _userReadingProgress!.status);
                                  },
                                  child: const Text('Update Progress'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Text('No reading progress recorded for this book.'),
              const SizedBox(height: 20),
              // User Review Section - Now at the bottom
              const Text(
                'User Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 10),
              _isLoadingReviews
                  ? const Center(child: CircularProgressIndicator())
                  : _reviews.isEmpty
                      ? const Text('No reviews yet. Be the first to review!')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Placeholder for user profile image
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppColors.lightBlue,
                                          child: Text(
                                            review.user?.name?.substring(0, 1).toUpperCase() ?? '?',
                                            style: const TextStyle(color: AppColors.darkBlue),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.user?.name ?? 'Anonymous', // Fallback to 'Anonymous' if name is null
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            RatingStarsDisplay(rating: review.rating),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review.comment ?? 'No comment provided.',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // Assuming this is part of home flow
    );
  }

  Future<void> _showUpdateProgressDialog(int initialPage, ReadingStatus initialStatus) async {
    // Check if the widget is still mounted before using context
    if (!mounted) return;

    int? newPage = initialPage;
    ReadingStatus? newStatus = initialStatus;

    await showDialog(
      context: context, // 'context' is now safe to use here
      builder: (BuildContext dialogContext) { // Changed parameter name to dialogContext
        return AlertDialog(
          title: const Text('Update Reading Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: initialPage.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Current Page'),
                onChanged: (value) {
                  newPage = int.tryParse(value);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ReadingStatus>(
                value: initialStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ReadingStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.value.capitalize()),
                  );
                }).toList(),
                onChanged: (status) {
                  newStatus = status;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext
              },
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                if (newPage != null && newStatus != null) {
                  if (newPage! > (widget.ebook.pageNumber ?? 999999)) {
                    // Check if the dialog context is still valid before showing SnackBar
                    if (Navigator.of(dialogContext).mounted) { // Use dialogContext
                      ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext
                        const SnackBar(content: Text('Current page cannot exceed total pages.'), backgroundColor: Colors.red),
                      );
                    }
                    return;
                  }
                  try {
                    await Provider.of<SupabaseService>(dialogContext, listen: false).updateReadingProgress( // Use dialogContext
                      userId: _userId!,
                      bookId: widget.ebook.ebookId,
                      currentPage: newPage!,
                      status: newStatus!,
                    );
                    // Check if the dialog context is still valid before showing SnackBar
                    if (Navigator.of(dialogContext).mounted) { // Use dialogContext
                      ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext
                        const SnackBar(content: Text('Reading progress updated!'), backgroundColor: Colors.green),
                      );
                    }
                    Navigator.of(dialogContext).pop(); // Use dialogContext
                    _fetchBookDetails(); // Refresh details
                  } catch (e) {
                    // Check if the dialog context is still valid before showing SnackBar
                    if (Navigator.of(dialogContext).mounted) { // Use dialogContext
                      ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext
                        SnackBar(content: Text('Failed to update progress: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  // Check if the dialog context is still valid before showing SnackBar
                  if (Navigator.of(dialogContext).mounted) { // Use dialogContext
                    ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext
                      const SnackBar(content: Text('Please enter valid page and status.'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}