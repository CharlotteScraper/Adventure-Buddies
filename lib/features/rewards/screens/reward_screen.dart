import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/reward_item.dart';
import '../../../data/repositories/reward_repository.dart';
import '../../../data/repositories/profile_repository.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceIn;
  List<RewardItem> _newRewards = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _bounceIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
    _loadNewRewards();
  }

  Future<void> _loadNewRewards() async {
    final profile = context.read<ProfileRepository>().activeProfile;
    if (profile == null) return;
    final rewards =
        await context.read<RewardRepository>().getNewRewards(profile.id!);
    if (mounted) {
      setState(() => _newRewards = rewards);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _collectAll() async {
    final profile = context.read<ProfileRepository>().activeProfile;
    if (profile == null) return;
    for (final reward in _newRewards) {
      await context
          .read<RewardRepository>()
          .markAsSeen(profile.id!, reward.itemId);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              ScaleTransition(
                scale: _bounceIn,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.sunnyYellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    size: 60,
                    color: AppColors.sunnyYellow,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'You earned a reward!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                    ),
              ),

              const SizedBox(height: 16),

              if (_newRewards.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Keep playing to collect stickers and badges!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    itemCount: _newRewards.length,
                    itemBuilder: (context, index) {
                      final reward = _newRewards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _rewardColor(reward.type).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _rewardIcon(reward.type),
                              color: _rewardColor(reward.type),
                            ),
                          ),
                          title: Text(
                            reward.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          subtitle: Text(reward.type),
                        ),
                      );
                    },
                  ),
                ),

              const Spacer(flex: 1),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _collectAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sunnyYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Collect!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Color _rewardColor(String type) {
    switch (type) {
      case 'sticker':
        return AppColors.sunnyYellow;
      case 'badge':
        return AppColors.playfulPink;
      case 'accessory':
        return AppColors.buddyBlue;
      default:
        return AppColors.leafyGreen;
    }
  }

  IconData _rewardIcon(String type) {
    switch (type) {
      case 'sticker':
        return Icons.auto_awesome;
      case 'badge':
        return Icons.verified;
      case 'accessory':
        return Icons.backpack;
      default:
        return Icons.card_giftcard;
    }
  }
}