import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final int starCount;
  final int currentStars;
  final double size;

  const StarRating({
    super.key,
    this.starCount = 3,
    this.currentStars = 0,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            index < currentStars
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: AppColors.sunnyYellow,
            size: size,
          ),
        );
      }),
    );
  }
}