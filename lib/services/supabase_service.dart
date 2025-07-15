// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart' as sup; // Added 'as sup' alias
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/collection.dart';
import '../models/reading_progress.dart';
import '../models/review.dart';
import '../models/wishlist.dart';

class SupabaseService {
  final sup.SupabaseClient _supabaseClient; // Corrected type to sup.SupabaseClient
  final Uuid _uuid = const Uuid();

  SupabaseService(this._supabaseClient);

  // --- User Authentication (Custom - using 'users' table directly) ---

  /// Logs in a user by checking credentials against the 'users' table.
  ///
  /// WARNING: This method performs a direct password comparison, which is
  /// highly insecure for production environments. Passwords should always
  /// be hashed and salted on the server-side.
  Future<User?> loginUser(String email, String password) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password) // Insecure: direct password comparison
          .single(); // Removed .execute()

      if (response != null) {
        final user = User.fromJson(response);
        if (user.role == Role.reader) {
          return user;
        } else {
          throw Exception('Only reader accounts can log in via this app.');
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Invalid email or password.');
    }
  }

  /// Registers a new user by inserting into the 'users' table.
  ///
  /// WARNING: This method stores the password in plain text, which is
  /// highly insecure for production environments. Passwords should always
  /// be hashed and salted on the server-side.
  Future<User> signUpUser({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final userId = _uuid.v4(); // Generate a new UUID for the user
      final newUser = User(
        id: userId,
        name: name,
        email: email,
        password: password, // Insecure: storing plain text password
        role: Role.reader, // Default role for app users
      );

      final response = await _supabaseClient
          .from('users')
          .insert(newUser.toJson())
          .select()
          .single(); // Removed .execute()

      return User.fromJson(response);
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Failed to sign up. Email might already be in use.');
    }
  }

  // --- Ebook Operations ---

  Future<List<Ebook>> fetchAllEbooks() async {
    try {
      final response = await _supabaseClient.from('ebook').select(); // Removed .execute()
      return (response as List).map((json) => Ebook.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching ebooks: $e');
      return [];
    }
  }

  Future<List<Ebook>> searchEbooksByTitle(String query) async {
    try {
      final response = await _supabaseClient
          .from('ebook')
          .select()
          .ilike('title', '%$query%'); // Removed .execute()
      return (response as List).map((json) => Ebook.fromJson(json)).toList();
    } catch (e) {
      print('Error searching ebooks by title: $e');
      return [];
    }
  }

  Future<List<Ebook>> searchEbooksByGenre(String genre) async {
    try {
      final response = await _supabaseClient
          .from('ebook')
          .select()
          .ilike('genre', '%$genre%'); // Removed .execute()
      return (response as List).map((json) => Ebook.fromJson(json)).toList();
    } catch (e) {
      print('Error searching ebooks by genre: $e');
      return [];
    }
  }

  // --- Collection Operations ---

  Future<List<Collection>> fetchUserCollections(String userId) async {
    try {
      final response = await _supabaseClient
          .from('collections')
          .select('*, ebook(*)') // Join with ebook table
          .eq('user_id', userId); // Removed .execute()
      return (response as List)
          .map((json) => Collection.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching user collections: $e');
      return [];
    }
  }

  Future<void> addBookToCollection(String userId, int bookId) async {
    try {
      await _supabaseClient.from('collections').insert({
        'user_id': userId,
        'book_id': bookId,
      }); // Removed .execute()
    } catch (e) {
      print('Error adding book to collection: $e');
      throw Exception('Failed to add book to collection.');
    }
  }

  Future<void> removeBookFromCollection(String collectionId) async {
    try {
      await _supabaseClient.from('collections').delete().eq('id', collectionId); // Removed .execute()
    } catch (e) {
      print('Error removing book from collection: $e');
      throw Exception('Failed to remove book from collection.');
    }
  }

  // --- Reading Progress Operations ---

  Future<List<ReadingProgress>> fetchUserReadingProgress(String userId) async {
    try {
      final response = await _supabaseClient
          .from('reading_progress')
          .select('*, ebook(*)') // Join with ebook table
          .eq('user_id', userId); // Removed .execute()
      return (response as List)
          .map((json) => ReadingProgress.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching user reading progress: $e');
      return [];
    }
  }

  Future<void> updateReadingProgress({
    required String userId,
    required int bookId,
    required int currentPage,
    required ReadingStatus status,
  }) async {
    try {
      // Check if a record already exists for this user and book
      final existingProgress = await _supabaseClient
          .from('reading_progress')
          .select()
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle(); // Changed .single().execute() to .maybeSingle()

      if (existingProgress != null) { // Check if data is not null directly
        // Update existing record
        await _supabaseClient.from('reading_progress').update({
          'current_page': currentPage,
          'status': status.value,
        }).eq('id', existingProgress['id']); // Removed .execute()
      } else {
        // Insert new record
        await _supabaseClient.from('reading_progress').insert({
          'user_id': userId,
          'book_id': bookId,
          'current_page': currentPage,
          'status': status.value,
        }); // Removed .execute()
      }
    } catch (e) {
      print('Error updating reading progress: $e');
      throw Exception('Failed to update reading progress.');
    }
  }

  // --- Review Operations ---

  Future<List<Review>> fetchBookReviews(int bookId) async {
    try {
      final response = await _supabaseClient
          .from('reviews')
          .select('*, users(name)') // Join with users table to get reviewer name
          .eq('book_id', bookId); // Removed .execute()
      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching book reviews: $e');
      return [];
    }
  }

  Future<void> addReview({
    required String userId,
    required int bookId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _supabaseClient.from('reviews').insert({
        'user_id': userId,
        'book_id': bookId,
        'rating': rating,
        'comment': comment,
      }); // Removed .execute()
    } catch (e) {
      print('Error adding review: $e');
      throw Exception('Failed to add review. You might have already reviewed this book.');
    }
  }

  // --- Wishlist Operations ---

  Future<List<Wishlist>> fetchUserWishlist(String userId) async {
    try {
      final response = await _supabaseClient
          .from('wishlists')
          .select()
          .eq('user_id', userId); // Removed .execute()
      return (response as List).map((json) => Wishlist.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching user wishlist: $e');
      return [];
    }
  }

  Future<void> addWishlistItem({
    required String userId,
    required String bookTitle,
    String? bookAuthor,
  }) async {
    try {
      // processed_by is NOT NULL in schema. Assigning current user's ID as a placeholder.
      // In a real app, this might be handled by a backend trigger or a default system user.
      await _supabaseClient.from('wishlists').insert({
        'user_id': userId,
        'book_title': bookTitle,
        'book_author': bookAuthor,
        'processed_by': userId, // Placeholder: assuming reader is "processing" their own request initially
        'status': BookStatus.notReviewed.value, // Default status
      }); // Removed .execute()
    } catch (e) {
      print('Error adding wishlist item: $e');
      throw Exception('Failed to add book to wishlist.');
    }
  }

  Future<void> removeWishlistItem(String wishlistId) async {
    try {
      await _supabaseClient.from('wishlists').delete().eq('id', wishlistId); // Removed .execute()
    } catch (e) {
      print('Error removing wishlist item: $e');
      throw Exception('Failed to remove book from wishlist.');
    }
  }
}