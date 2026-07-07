import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart' as constants;

class LargeButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;
  final double minWidth;
  final double height;
  final bool isLoading;

  const LargeButton({
    super.key,
    required this.text,
    this.icon,
    this.color = AppColors.buddyBlue,
    this.textColor = Colors.white,
    this.onPressed,
    this.minWidth = constants.AppConstants.buttonMinWidth,
    this.height = 64,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minWidth,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 24),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}