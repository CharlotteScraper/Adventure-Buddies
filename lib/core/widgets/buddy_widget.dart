import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BuddyWidget extends StatelessWidget {
  final String type;
  final Color color;
  final String? hat;
  final double size;

  const BuddyWidget({
    super.key,
    this.type = 'fox',
    this.color = const Color(0xFFF0C080),
    this.hat,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    IconData buddyIcon;
    switch (type) {
      case 'bear':
        buddyIcon = Icons.face_2;
        break;
      case 'bunny':
        buddyIcon = Icons.face_4;
        break;
      case 'cat':
        buddyIcon = Icons.face_5;
        break;
      default:
        buddyIcon = Icons.face_3;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hat != null && hat != 'none') ...[
          Icon(
            _hatIcon(hat!),
            size: size * 0.4,
            color: AppColors.playfulPink,
          ),
          const SizedBox(height: 4),
        ],
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(
            buddyIcon,
            size: size * 0.55,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _hatIcon(String hat) {
    switch (hat) {
      case 'crown':
        return Icons.workspace_premium;
      case 'party':
        return Icons.celebration;
      case 'captain':
        return Icons.flight;
      default:
        return Icons.emoji_people;
    }
  }
}