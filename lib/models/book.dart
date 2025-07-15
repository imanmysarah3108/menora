// lib/models/book.dart
class Ebook {
  final int ebookId;
  final String? author;
  final String title;
  final int? pageNumber;
  final double? price;
  final int? yearPublished;
  final String? publisher;
  final String? genre;

  Ebook({
    required this.ebookId,
    this.author,
    required this.title,
    this.pageNumber,
    this.price,
    this.yearPublished,
    this.publisher,
    this.genre,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      ebookId: json['ebook_id'],
      author: json['author'],
      title: json['title'],
      pageNumber: json['page_number'],
      price: (json['price'] as num?)?.toDouble(),
      yearPublished: json['year_published'],
      publisher: json['publisher'],
      genre: json['genre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ebook_id': ebookId,
      'author': author,
      'title': title,
      'page_number': pageNumber,
      'price': price,
      'year_published': yearPublished,
      'publisher': publisher,
      'genre': genre,
    };
  }
}