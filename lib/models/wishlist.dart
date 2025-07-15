// lib/models/wishlist.dart
import 'user.dart';
enum BookStatus {
  notReviewed('not reviewed'),
  available('available');

  final String value;
  const BookStatus(this.value);

  factory BookStatus.fromString(String status) {
    return BookStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => BookStatus.notReviewed,
    );
  }
}

class Wishlist {
  final String id;
  final String userId;
  final String bookTitle;
  final String? bookAuthor;
  final String processedBy;
  final BookStatus status;
  final User? user; // Joined user data (processed_by)

  Wishlist({
    required this.id,
    required this.userId,
    required this.bookTitle,
    this.bookAuthor,
    required this.processedBy,
    required this.status,
    this.user,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'],
      userId: json['user_id'],
      bookTitle: json['book_title'],
      bookAuthor: json['book_author'],
      processedBy: json['processed_by'],
      status: BookStatus.fromString(json['status']),
      user: json['users'] != null ? User.fromJson(json['users']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'processed_by': processedBy,
      'status': status.value,
    };
  }
}