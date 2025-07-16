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
import 'dart:math';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // Check if the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final currentUser = Provider.of<CurrentUser>(context, listen: false);
    _userId = currentUser.user?.id;

    if (_userId == null) {
      // If user is not logged in, navigate to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      });
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
      if (mounted) { // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) { // Check mounted before calling setState in finally block
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
        title: const Text(
          'MENoRA',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                                      ? const Icon(Icons.book, size: 60, color: AppColors.greyText)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 20),
                  // Genre Filters (now in SearchResultsScreen)
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}