import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/constants/app_constants.dart' as constants;
import '../../world_map/models/world.dart';
import '../../learning_activities/activity_template_screen.dart';
import '../../learning_activities/forest_letters/letter_matching_activity.dart';
import '../../learning_activities/number_beach/count_seashells_activity.dart';
import '../../learning_activities/shape_city/shape_building_activity.dart';
import '../../learning_activities/feelings_garden/emotion_matching_activity.dart';

class WorldDetailScreen extends StatefulWidget {
  final World world;

  const WorldDetailScreen({super.key, required this.world});

  @override
  State<WorldDetailScreen> createState() => _WorldDetailScreenState();
}

class _WorldDetailScreenState extends State<WorldDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideIn = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NarrationService>()
          .speak('Welcome to ${widget.world.name}!');
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openActivity(Activity activity) {
    Widget targetScreen;

    // Route to specific game activity based on ID
    switch (activity.id) {
      case 'find_letter':
        targetScreen = const LetterMatchingActivity();
        break;
      case 'count_seashells':
        targetScreen = const CountSeashellsActivity();
        break;
      case 'build_house':
        targetScreen = const ShapeBuildingActivity();
        break;
      case 'emotion_match':
        targetScreen = const EmotionMatchingActivity();
        break;
      default:
        targetScreen = ActivityTemplateScreen(
          activity: activity,
          worldColor: widget.world.primaryColor,
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final world = widget.world;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              world.primaryColor,
              world.secondaryColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _slideIn,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _slideIn.value * 50),
              child: child,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button & title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),
                      const Spacer(),
                      Text(
                        world.name,
                        style: const TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Activities list
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            world.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Activities',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 16),

                          // Activity cards
                          Expanded(
                            child: ListView.separated(
                              itemCount: world.activities.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final activity = world.activities[index];
                                return _ActivityCard(
                                  activity: activity,
                                  worldColor: world.primaryColor,
                                  onTap: () => _openActivity(activity),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final Color worldColor;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.worldColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100, width: 2),
          boxShadow: [
            BoxShadow(
              color: worldColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Activity icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: worldColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(activity.icon, color: worldColor, size: 28),
            ),
            const SizedBox(width: 16),
            // Activity info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}