import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/constants/app_constants.dart' as constants;
import '../../world_map/models/world.dart';

class ActivityTemplateScreen extends StatefulWidget {
  final Activity activity;
  final Color worldColor;

  const ActivityTemplateScreen({
    super.key,
    required this.activity,
    required this.worldColor,
  });

  @override
  State<ActivityTemplateScreen> createState() => _ActivityTemplateScreenState();
}

class _ActivityTemplateScreenState extends State<ActivityTemplateScreen>
    with TickerProviderStateMixin {
  int _stars = 0;
  bool _isComplete = false;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NarrationService>()
          .speak("Let's do ${widget.activity.name}!");
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _onCorrectAction() {
    if (_isComplete) return;
    context.read<AudioService>().playCorrectAction();
    setState(() {
      _stars = (_stars + 1).clamp(0, constants.AppConstants.maxStarsPerActivity);
      if (_stars >= 3) {
        _isComplete = true;
        context.read<AudioService>().playRewardJingle();
        context.read<NarrationService>().sayComplete();
      } else {
        context.read<NarrationService>().sayCorrect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.worldColor,
              widget.worldColor.withOpacity(0.6),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Home',
                    ),
                    const Spacer(),
                    // Stars display
                    Row(
                      children: List.generate(
                          constants.AppConstants.maxStarsPerActivity, (i) {
                        return Icon(
                          i < _stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.sunnyYellow,
                          size: 36,
                        );
                      }),
                    ),
                    const Spacer(),
                    // Instructions button
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        context.read<NarrationService>().speak(
                              activity.description,
                            );
                      },
                      tooltip: 'Instructions',
                    ),
                  ],
                ),
              ),

              // Activity title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  activity.name,
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
              ),

              // Activity area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: widget.worldColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          activity.icon,
                          size: 80,
                          color: widget.worldColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          activity.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 32),

                        // Tap to interact (placeholder)
                        GestureDetector(
                          onTap: _onCorrectAction,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: widget.worldColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.worldColor.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: _isComplete
                                ? const Icon(Icons.check_circle_rounded,
                                    size: 80, color: AppColors.successGreen)
                                : Icon(Icons.touch_app_rounded,
                                    size: 60,
                                    color: widget.worldColor),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isComplete
                              ? 'Amazing! 🌟'
                              : 'Tap the circle to play!',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom padding
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}