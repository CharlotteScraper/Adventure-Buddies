import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/repositories/reward_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _weeklyStats = {};
  double _missionRate = 0.0;
  int _rewardCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = context.read<ProfileRepository>().activeProfile;
    if (profile == null) {
      setState(() => _isLoading = false);
      return;
    }

    final stats = await context
        .read<ProgressRepository>()
        .getWeeklyStats(profile.id!);
    final rate =
        await context.read<MissionRepository>().getCompletionRate(profile.id!);
    final rewards = await context
        .read<RewardRepository>()
        .getRewardCount(profile.id!);

    if (mounted) {
      setState(() {
        _weeklyStats = stats;
        _missionRate = rate;
        _rewardCount = rewards;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textPrimary),
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/'),
                        ),
                        const Spacer(),
                        Text(
                          'Parent Dashboard',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                              ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly stats card
                    _buildStatCard(
                      'This Week',
                      Icons.timeline_rounded,
                      AppColors.buddyBlue,
                      [
                        _buildStatItem(
                          'Play Time',
                          '${_weeklyStats['minutes'] ?? 0} min',
                          Icons.timer_rounded,
                          AppColors.oceanTurquoise,
                        ),
                        _buildStatItem(
                          'Activities',
                          '${_weeklyStats['activities'] ?? 0}',
                          Icons.celebration_rounded,
                          AppColors.sunnyYellow,
                        ),
                        _buildStatItem(
                          'Sessions',
                          '${_weeklyStats['sessions'] ?? 0}',
                          Icons.play_circle_rounded,
                          AppColors.leafyGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Learning progress card
                    _buildStatCard(
                      'Learning Progress',
                      Icons.school_rounded,
                      AppColors.royalPurple,
                      [
                        _buildProgressWorldItem(
                          'Forest of Letters',
                          AppColors.forestGreen,
                          0.6,
                        ),
                        _buildProgressWorldItem(
                          'Number Beach',
                          AppColors.oceanTurquoise,
                          0.3,
                        ),
                        _buildProgressWorldItem(
                          'Shape City',
                          AppColors.royalPurple,
                          0.0,
                        ),
                        _buildProgressWorldItem(
                          'Feelings Garden',
                          AppColors.lavender,
                          0.0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mission stats card
                    _buildStatCard(
                      'Real World Missions',
                      Icons.directions_run_rounded,
                      AppColors.coralOrange,
                      [
                        _buildStatItem(
                          'Completion Rate',
                          '${(_missionRate * 100).round()}%',
                          Icons.check_circle_rounded,
                          AppColors.successGreen,
                        ),
                        _buildStatItem(
                          'Rewards Earned',
                          '$_rewardCount',
                          Icons.card_giftcard_rounded,
                          AppColors.playfulPink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Settings section
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      'Sound',
                      Icons.volume_up_rounded,
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      'Screen Time Limit',
                      Icons.timer_rounded,
                      subtitle: 'No limit set',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      'Reset Progress',
                      Icons.delete_forever_rounded,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Reset Progress?'),
                            content: const Text(
                              'This will delete all progress for all children. This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Reset database
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: AppColors.errorRed),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // COPPA disclaimer
                    Center(
                      child: Text(
                        'Adventure Buddies is COPPA-compliant.\nNo data is collected or shared.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressWorldItem(
      String name, Color color, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}