// lib/models/review.dart
import 'book.dart';
import 'user.dart';
class Review {
  final String id;
  final String userId;
  final int rating;
  final String? comment;
  final int? bookId;
  final User? user; // Joined user data
  final Ebook? ebook; // Joined ebook data

  Review({
    required this.id,
    required this.userId,
    required this.rating,
    this.comment,
    this.bookId,
    this.user,
    this.ebook,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      bookId: json['book_id'],
      user: json['users'] != null ? User.fromJson(json['users']) : null,
      ebook: json['ebook'] != null ? Ebook.fromJson(json['ebook']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'book_id': bookId,
    };
  }
}
