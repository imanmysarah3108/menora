// lib/widgets/book_card.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../constants/app_colors.dart';
import 'dart:math';


class BookCard extends StatelessWidget {
  final Ebook ebook;
  final VoidCallback onTap;
  final bool showProgress;
  final int? currentPage;
  final String? statusText;

  const BookCard({
    super.key,
    required this.ebook,
    required this.onTap,
    this.showProgress = false,
    this.currentPage,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for book cover image
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/seed/${Random().nextInt(1000)}/200/300',
                    ),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback for image loading errors
                      print('Error loading image: $exception');
                    },
                  ),
                ),
                alignment: Alignment.center,
                child: ebook.title.isEmpty
                    ? const Icon(Icons.book, size: 40, color: AppColors.greyText)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ebook.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ebook.author != null && ebook.author!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          ebook.author!,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (showProgress) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Page: ${currentPage ?? 0}/${ebook.pageNumber ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (statusText != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusText == 'completed' ? AppColors.green.withOpacity(0.2) : AppColors.primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            statusText!,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusText == 'completed' ? AppColors.green : AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ] else if (ebook.genre != null && ebook.genre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Genre: ${ebook.genre!}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.greyText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}