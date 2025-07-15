// lib/screens/home/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_router.dart';
import '../../widgets/book_card.dart';
import '../../services/supabase_service.dart';
import '../../models/book.dart';
import '../auth/login_screen.dart'; // To access CurrentUser
import '../../widgets/custom_button.dart'; // For "add to wishlist now" button
import '../../widgets/custom_text_field.dart'; // For search input
class SearchResultsScreen extends StatefulWidget {
  final String? genre;
  final String? initialQuery;

  const SearchResultsScreen({super.key, this.genre, this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Ebook> _searchResults = [];
  bool _isLoading = false;
  String? _currentSearchTerm;
  String? _currentGenre;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _currentSearchTerm = widget.initialQuery;
    _currentGenre = widget.genre;
    _userId = Provider.of<CurrentUser>(context, listen: false).user?.id;
    if (_userId == null) {
      Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      return;
    }
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      if (_currentGenre != null && _currentGenre!.isNotEmpty) {
        _searchResults = await supabaseService.searchEbooksByGenre(_currentGenre!);
      } else if (_currentSearchTerm != null && _currentSearchTerm!.isNotEmpty) {
        _searchResults = await supabaseService.searchEbooksByTitle(_currentSearchTerm!);
      } else {
        _searchResults = []; // No search term or genre, show empty results
      }
    } catch (e) {
      print('Error performing search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _currentSearchTerm = query;
      _currentGenre = null; // Clear genre when performing text search
    });
    _performSearch();
  }

  Future<void> _addBookToWishlist() async {
    if (_userId == null) return;

    // Prompt user for book title and author
    String? bookTitle;
    String? bookAuthor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController authorController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Book to Wishlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: titleController,
                hintText: 'Book Title (Required)',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: authorController,
                hintText: 'Book Author (Optional)',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  bookTitle = titleController.text;
                  bookAuthor = authorController.text.isNotEmpty ? authorController.text : null;
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book title is required!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (bookTitle != null) {
      try {
        final supabaseService = Provider.of<SupabaseService>(context, listen: false);
        await supabaseService.addWishlistItem(
          userId: _userId!,
          bookTitle: bookTitle!,
          bookAuthor: bookAuthor,
        );
        _showSnackBar('Book added to wishlist!', Colors.green);
      } catch (e) {
        _showSnackBar('Failed to add to wishlist: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
      }
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Search Results',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        toolbarHeight: 0, // Hide default app bar
      ),
      body: Column(
        children: [
          // Top blue search bar area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: AppColors.white),
                    prefixIcon: const Icon(Icons.search, color: AppColors.white),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: const TextStyle(color: AppColors.white),
                ),
                if (_currentGenre != null && _currentGenre!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text('Genre: $_currentGenre'),
                        backgroundColor: AppColors.lightBlue,
                        labelStyle: const TextStyle(color: AppColors.darkBlue),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _currentGenre = null;
                            _searchController.clear();
                            _searchResults = []; // Clear results when genre is cleared
                          });
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Book not found',
                              style: TextStyle(fontSize: 18, color: AppColors.greyText),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              text: 'add to wishlist now',
                              onPressed: _addBookToWishlist,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final ebook = _searchResults[index];
                          return BookCard(
                            ebook: ebook,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.bookDetailRoute,
                                arguments: ebook,
                              );
                            },
                            showProgress: true, // Assuming search results might show progress
                            statusText: 'Complete', // Placeholder, ideally fetched from reading_progress
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}