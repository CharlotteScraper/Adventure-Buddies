import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/models/mission_record.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/repositories/profile_repository.dart';

class MissionScreen extends StatefulWidget {
  final MissionRecord mission;

  const MissionScreen({super.key, required this.mission});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with TickerProviderStateMixin {
  bool _isDone = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NarrationService>().speak(
            'Time to move! ${widget.mission.title}',
          );
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onDone() async {
    setState(() => _isDone = true);
    context.read<AudioService>().playRewardJingle();
    context.read<NarrationService>().speak('Great moving!');
    await context
        .read<MissionRepository>()
        .completeMission(widget.mission.id!);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.sunnyYellow.withOpacity(0.8),
              AppColors.sunnyYellow.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Mission header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.coralOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_run,
                          color: AppColors.coralOrange, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Move Your Body!',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 24,
                          color: AppColors.coralOrange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Mission illustration area
                ScaleTransition(
                  scale: _bounceAnim,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sunnyYellow.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getMissionIcon(mission.missionId),
                      size: 90,
                      color: AppColors.coralOrange,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Mission title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    mission.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                        ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Can you do it?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const Spacer(flex: 1),

                // Done button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isDone ? null : _onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDone
                            ? AppColors.successGreen
                            : AppColors.leafyGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        _isDone ? 'Done! 🌟' : 'Done!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMissionIcon(String missionId) {
    switch (missionId) {
      case 'hop_frog':
        return Icons.arrow_upward_rounded;
      case 'stomp_feet':
        return Icons.hearing_rounded;
      case 'touch_toes':
        return Icons.air;
      case 'spin_around':
        return Icons.autorenew_rounded;
      case 'high_knees':
        return Icons.arrow_upward;
      case 'wiggle_fingers':
        return Icons.pan_tool_rounded;
      case 'clap_hands':
        return Icons.handshake_rounded;
      case 'stretch_arms':
        return Icons.swap_vert_rounded;
      case 'balance_one_foot':
        return Icons.accessible_rounded;
      case 'jumping_jacks':
        return Icons.open_with_rounded;
      default:
        return Icons.directions_run;
    }
  }
}