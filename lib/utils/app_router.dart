// lib/utils/app_router.dart
import 'package:flutter/material.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/book_detail_screen.dart';
import '../screens/home/search_results_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/collection/collection_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/review/review_screen.dart';
import '../models/book.dart'; // Import the Book model for passing to BookDetailScreen

class AppRouter {
  static const String welcomeRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String bookDetailRoute = '/bookDetail';
  static const String searchResultsRoute = '/searchResults';
  static const String wishlistRoute = '/wishlist';
  static const String collectionRoute = '/collection';
  static const String profileRoute = '/profile';
  static const String reviewRoute = '/review';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcomeRoute:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signupRoute:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case bookDetailRoute:
        final args = settings.arguments as Ebook;
        return MaterialPageRoute(builder: (_) => BookDetailScreen(ebook: args));
      case searchResultsRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
                  genre: args['genre'],
                  initialQuery: args['query'],
                ));
      case wishlistRoute:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());
      case collectionRoute:
        return MaterialPageRoute(builder: (_) => const CollectionScreen());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case reviewRoute:
        final args = settings.arguments as Ebook;
        return MaterialPageRoute(builder: (_) => ReviewScreen(ebook: args));
      default:
        return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
    }
  }
}