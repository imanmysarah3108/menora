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
import '../../widgets/custom_text_field.dart'; // For search input field
import '../../widgets/bottom_nav_bar.dart'; // For bottom navigation bar

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
    debugPrint('SearchResultsScreen: initState called.');
    _searchController.text = widget.initialQuery ?? '';
    _currentSearchTerm = widget.initialQuery;
    _currentGenre = widget.genre;

    _userId = Provider.of<CurrentUser>(context, listen: false).user?.id;
    debugPrint('SearchResultsScreen: userId in initState: $_userId');

    if (_userId == null) {
      debugPrint('SearchResultsScreen: userId is null. Scheduling navigation to login.');
      // Schedule navigation after the current frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure widget is still mounted before navigating
          Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
        }
      });
    } else {
      // Only perform search if a user is logged in
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    debugPrint('SearchResultsScreen: _performSearch called.');
    setState(() {
      _isLoading = true;
    });
    debugPrint('SearchResultsScreen: _isLoading set to true.');

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      if (_currentGenre != null && _currentGenre!.isNotEmpty) {
        debugPrint('SearchResultsScreen: Searching by genre: $_currentGenre');
        _searchResults = await supabaseService.searchEbooksByGenre(_currentGenre!);
      } else if (_currentSearchTerm != null && _currentSearchTerm!.isNotEmpty) {
        debugPrint('SearchResultsScreen: Searching by title: $_currentSearchTerm');
        _searchResults = await supabaseService.searchEbooksByTitle(_currentSearchTerm!);
      } else {
        debugPrint('SearchResultsScreen: No search term or genre, clearing results.');
        _searchResults = []; // No search term or genre, show empty results
      }
      debugPrint('SearchResultsScreen: Search results count: ${_searchResults.length}');
    } catch (e) {
      debugPrint('SearchResultsScreen: Error performing search: $e');
      if (mounted) { // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) { // Check mounted before calling setState in finally block
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('SearchResultsScreen: _isLoading set to false.');
    }
  }

  void _onSearchSubmitted(String query) {
    debugPrint('SearchResultsScreen: _onSearchSubmitted called with query: $query');
    setState(() {
      _currentSearchTerm = query;
      _currentGenre = null; // Clear genre when performing text search
    });
    _performSearch();
  }

  Future<void> _addBookToWishlist() async {
    debugPrint('SearchResultsScreen: _addBookToWishlist called.');
    if (_userId == null) {
      debugPrint('SearchResultsScreen: userId is null, cannot add to wishlist.');
      return;
    }

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
        debugPrint('SearchResultsScreen: Book added to wishlist successfully.');
      } catch (e) {
        _showSnackBar('Failed to add to wishlist: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
        debugPrint('SearchResultsScreen: Failed to add to wishlist: $e');
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
    debugPrint('SearchResultsScreen: dispose called.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SearchResultsScreen: build called. _isLoading: $_isLoading, _searchResults.isEmpty: ${_searchResults.isEmpty}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Search Books',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Search by title',
                hintStyle: const TextStyle(color: AppColors.greyText),
                prefixIcon: const Icon(Icons.search, color: AppColors.greyText),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.greyText),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _currentSearchTerm = null;
                            _searchResults = [];
                          });
                          debugPrint('SearchResultsScreen: Search field cleared.');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: AppColors.black),
            ),
          ),
          // Genre Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildGenreChip('Popular'),
                _buildGenreChip('Horror'),
                _buildGenreChip('Romance'),
                _buildGenreChip('Fantasy'),
                _buildGenreChip('Science Fiction'),
                _buildGenreChip('Thriller'),
              ],
            ),
          ),
          if (_currentGenre != null && _currentGenre!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Genre: $_currentGenre'),
                  backgroundColor: AppColors.lightBlue,
                  labelStyle: const TextStyle(color: AppColors.white),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _currentGenre = null;
                      _searchController.clear();
                      _searchResults = []; // Clear results when genre is cleared
                    });
                    debugPrint('SearchResultsScreen: Genre chip deleted.');
                  },
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No books found. Try a different search or add to wishlist.',
                              style: TextStyle(fontSize: 18, color: AppColors.greyText),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              text: 'Add to Wishlist Now',
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
                            showProgress: false, // Search results don't necessarily show progress
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1), // Set to 1 for Search tab
    );
  }

  Widget _buildGenreChip(String genre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(genre),
        backgroundColor: const Color.fromARGB(255, 198, 221, 244),
        labelStyle: const TextStyle(color: AppColors.darkBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        onPressed: () {
          setState(() {
            _currentGenre = genre;
            _currentSearchTerm = null; // Clear search term when genre is selected
            _searchController.clear();
          });
          _performSearch();
          debugPrint('SearchResultsScreen: Genre chip pressed: $genre');
        },
      ),
    );
  }
}