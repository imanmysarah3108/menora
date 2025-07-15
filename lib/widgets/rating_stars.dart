// lib/widgets/rating_stars.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../constants/app_colors.dart';

class RatingStarsDisplay extends StatelessWidget {
  final int rating;
  final double size;

  const RatingStarsDisplay({
    super.key,
    required this.rating,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: rating.toDouble(),
      starBuilder: (index, color) => Icon(
        Icons.star_rounded,
        color: color, // This color is provided by RatingStars based on value and starColor/starOffColor
        size: size,
      ),
      starCount: 5,
      starSize: size,
      valueLabelVisibility: false,
      animationDuration: Duration.zero,
      starColor: AppColors.starYellow,
      starOffColor: AppColors.lightGrey, // Use starOffColor for unselected stars
      // readOnly is implied when onValueChanged is not provided
    );
  }
}

class RatingStarsInput extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const RatingStarsInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: rating,
      onValueChanged: onRatingChanged,
      starBuilder: (index, color) => Icon(
        Icons.star_rounded,
        color: color, // This color is provided by RatingStars based on value and starColor/starOffColor
        size: size,
      ),
      starCount: 5,
      starSize: size,
      valueLabelVisibility: false,
      animationDuration: Duration.zero,
      starColor: AppColors.starYellow,
      starOffColor: AppColors.lightGrey, // Use starOffColor for unselected stars
    );
  }
}