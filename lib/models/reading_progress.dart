// lib/models/reading_progress.dart
import 'book.dart';
enum ReadingStatus {
  notStarted('not started'),
  reading('reading'),
  completed('completed');

  final String value;
  const ReadingStatus(this.value);

  factory ReadingStatus.fromString(String status) {
    return ReadingStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => ReadingStatus.notStarted,
    );
  }
}

class ReadingProgress {
  final String id;
  final String userId;
  final int bookId;
  final int currentPage;
  final ReadingStatus status;
  final Ebook? ebook; // Joined ebook data

  ReadingProgress({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.currentPage,
    required this.status,
    this.ebook,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      currentPage: json['current_page'],
      status: ReadingStatus.fromString(json['status']),
      ebook: json['ebook'] != null ? Ebook.fromJson(json['ebook']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'current_page': currentPage,
      'status': status.value,
    };
  }
}