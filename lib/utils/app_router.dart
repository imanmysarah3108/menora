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
import '../models/book.dart'; // Import Ebook model for arguments

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
        // Ensure arguments are of the correct type
        final args = settings.arguments;
        if (args is Ebook) {
          return MaterialPageRoute(builder: (_) => BookDetailScreen(ebook: args));
        }
        // Fallback for incorrect argument type
        return MaterialPageRoute(builder: (_) => const Text('Error: Invalid book arguments'));
      case searchResultsRoute:
        // Ensure arguments are of the correct type
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
              builder: (_) => SearchResultsScreen(
                    genre: args['genre'] as String?,
                    initialQuery: args['query'] as String?,
                  ));
        }
        // Fallback for incorrect argument type or no arguments
        return MaterialPageRoute(builder: (_) => const SearchResultsScreen());
      case wishlistRoute:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());
      case collectionRoute:
        return MaterialPageRoute(builder: (_) => const CollectionScreen());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case reviewRoute:
        // Ensure arguments are of the correct type
        final args = settings.arguments;
        if (args is Ebook) {
          return MaterialPageRoute(builder: (_) => ReviewScreen(ebook: args));
        }
        // Fallback for incorrect argument type
        return MaterialPageRoute(builder: (_) => const Text('Error: Invalid review arguments'));
      default:
        // This case handles any undefined routes
        return MaterialPageRoute(builder: (_) => Text('Error: Unknown route ${settings.name}'));
    }
  }
}