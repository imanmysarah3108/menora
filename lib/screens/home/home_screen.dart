// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_router.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/book_card.dart';
import '../../services/supabase_service.dart';
import '../../models/book.dart';
import '../auth/login_screen.dart'; // To access CurrentUser

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Ebook> _allEbooks = [];
  List<Ebook> _myCollection = [];
  List<Ebook> _exploreReads = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = Provider.of<CurrentUser>(context, listen: false);
    _userId = currentUser.user?.id;

    if (_userId == null) {
      // If user is not logged in, navigate to login screen
      Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      return;
    }

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);

      // Fetch all ebooks for "Explore Reads" and potential search
      _allEbooks = await supabaseService.fetchAllEbooks();
      _exploreReads = _allEbooks; // Initially, all ebooks are explore reads

      // Fetch user's collection
      final collections = await supabaseService.fetchUserCollections(_userId!);
      _myCollection = collections.map((c) => c.ebook!).whereType<Ebook>().toList();

    } catch (e) {
      print('Error fetching data for home screen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _exploreReads = _allEbooks; // Reset to all if query is empty
      });
    } else {
      // Navigate to search results screen with the query
      Navigator.pushNamed(
        context,
        AppRouter.searchResultsRoute,
        arguments: {'query': query, 'genre': null},
      );
    }
  }

  void _searchByGenre(String genre) {
    Navigator.pushNamed(
      context,
      AppRouter.searchResultsRoute,
      arguments: {'genre': genre, 'query': null},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide default app bar
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                        onSubmitted: _performSearch,
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // My Collection Section
                        const Text(
                          'My Collection',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _myCollection.isEmpty
                            ? const Text('No books in your collection yet.')
                            : SizedBox(
                                height: 200, // Height for horizontal scroll
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _myCollection.length,
                                  itemBuilder: (context, index) {
                                    final ebook = _myCollection[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRouter.bookDetailRoute,
                                          arguments: ebook,
                                        );
                                      },
                                      child: Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGrey,
                                          borderRadius: BorderRadius.circular(8.0),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              'https://placehold.co/120x180/BBDEFB/1E88E5?text=${ebook.title.substring(0, 1)}',
                                            ),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {
                                              print('Error loading image: $exception');
                                            },
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: ebook.title.isEmpty
                                            ? const Icon(Icons.book, size: 60, color: AppColors.greyText)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 20),
                        // Genre Filters
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
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
                        const SizedBox(height: 20),
                        // Explore Reads Section
                        const Text(
                          'Explore Reads',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _exploreReads.isEmpty
                            ? const Text('No books to explore.')
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
                                itemCount: _exploreReads.length,
                                itemBuilder: (context, index) {
                                  final ebook = _exploreReads[index];
                                  return BookCard(
                                    ebook: ebook,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.bookDetailRoute,
                                        arguments: ebook,
                                      );
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(genre),
        backgroundColor: AppColors.lightBlue,
        labelStyle: const TextStyle(color: AppColors.darkBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        onPressed: () => _searchByGenre(genre),
      ),
    );
  }
}