import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class World {
  final String id;
  final String name;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData icon;
  final String imageAsset;
  final String description;
  final List<Activity> activities;

  const World({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.icon,
    required this.imageAsset,
    required this.description,
    required this.activities,
  });

  static const List<World> allWorlds = [
    World(
      id: 'forest_letters',
      name: 'Forest of Letters',
      subtitle: 'ABCs & Phonics',
      primaryColor: AppColors.forestGreen,
      secondaryColor: AppColors.paleLeaf,
      accentColor: AppColors.treeBark,
      icon: Icons.forest_rounded,
      imageAsset: 'assets/images/world_forest_letters.png',
      description: 'Explore the forest and discover letters! Help animals find their names and learn the sounds they make.',
      activities: [
        Activity(id: 'letter_tracing', name: 'Letter Tracing', description: 'Trace letters with your finger', icon: Icons.edit, worldId: 'forest_letters'),
        Activity(id: 'letter_sounds', name: 'Letter Sounds', description: 'Match letters to their sounds', icon: Icons.record_voice_over, worldId: 'forest_letters'),
        Activity(id: 'find_letter', name: 'Find the Letter', description: 'Find the letter that makes the sound', icon: Icons.search, worldId: 'forest_letters'),
        Activity(id: 'word_building', name: 'Word Building', description: 'Build simple words', icon: Icons.text_fields, worldId: 'forest_letters'),
      ],
    ),
    World(
      id: 'number_beach',
      name: 'Number Beach',
      subtitle: 'Counting & Math',
      primaryColor: AppColors.oceanTurquoise,
      secondaryColor: AppColors.softSand,
      accentColor: AppColors.coralOrange,
      icon: Icons.beach_access_rounded,
      imageAsset: 'assets/images/world_number_beach.png',
      description: 'Count seashells, sort starfish, and splash through numbers at the beach!',
      activities: [
        Activity(id: 'count_seashells', name: 'Count Seashells', description: 'Count the seashells on the beach', icon: Icons.calculate, worldId: 'number_beach'),
        Activity(id: 'number_tracing', name: 'Number Tracing', description: 'Trace numbers in the sand', icon: Icons.edit, worldId: 'number_beach'),
        Activity(id: 'count_starfish', name: 'Sort Starfish', description: 'Sort starfish by size and number', icon: Icons.sort, worldId: 'number_beach'),
        Activity(id: 'beach_patterns', name: 'Beach Patterns', description: 'Complete the pattern on the sand', icon: Icons.grid_view, worldId: 'number_beach'),
      ],
    ),
    World(
      id: 'shape_city',
      name: 'Shape City',
      subtitle: 'Shapes & Space',
      primaryColor: AppColors.royalPurple,
      secondaryColor: AppColors.skyBlue,
      accentColor: AppColors.trafficYellow,
      icon: Icons.location_city_rounded,
      imageAsset: 'assets/images/world_shape_city.png',
      description: 'Build and explore a city made of shapes! Learn about squares, circles, triangles and more.',
      activities: [
        Activity(id: 'shape_match', name: 'Shape Match', description: 'Match shapes to their outlines', icon: Icons.category, worldId: 'shape_city'),
        Activity(id: 'build_house', name: 'Build a House', description: 'Drag shapes to build a house', icon: Icons.house, worldId: 'shape_city'),
        Activity(id: 'shape_hunt', name: 'Shape Hunt', description: 'Find all the circles in Shape City', icon: Icons.visibility, worldId: 'shape_city'),
        Activity(id: 'puzzle_pieces', name: 'Puzzle Pieces', description: 'Fit shapes into the puzzle', icon: Icons.extension, worldId: 'shape_city'),
      ],
    ),
    World(
      id: 'feelings_garden',
      name: 'Feelings Garden',
      subtitle: 'Emotions & Care',
      primaryColor: AppColors.lavender,
      secondaryColor: AppColors.softRose,
      accentColor: AppColors.coolMint,
      icon: Icons.local_florist_rounded,
      imageAsset: 'assets/images/world_feelings_garden.png',
      description: 'Tend to the garden and learn about feelings! Help the flowers bloom by understanding emotions.',
      activities: [
        Activity(id: 'emotion_match', name: 'Emotion Match', description: 'Match faces to feelings', icon: Icons.emoji_emotions, worldId: 'feelings_garden'),
        Activity(id: 'help_friends', name: 'Help Friends', description: 'Help garden friends with their feelings', icon: Icons.volunteer_activism, worldId: 'feelings_garden'),
        Activity(id: 'garden_care', name: 'Garden Care', description: 'Water flowers and make them bloom', icon: Icons.spa, worldId: 'feelings_garden'),
        Activity(id: 'feeling_sort', name: 'Feeling Sort', description: 'Sort happy, sad, and silly feelings', icon: Icons.sort, worldId: 'feelings_garden'),
      ],
    ),
  ];
}

class Activity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String worldId;

  const Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.worldId,
  });
}