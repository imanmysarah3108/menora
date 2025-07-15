// lib/models/collection.dart
import 'book.dart';

class Collection {
  final String id;
  final String userId;
  final int bookId;
  final Ebook? ebook; // Joined ebook data

  Collection({
    required this.id,
    required this.userId,
    required this.bookId,
    this.ebook,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      ebook: json['ebook'] != null ? Ebook.fromJson(json['ebook']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
    };
  }
}