import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/narration_service.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../world_detail/screens/world_detail_screen.dart';
import '../models/world.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NarrationService>().speak('Where do you want to go today?');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onWorldTap(World world) async {
    final profile = context.read<ProfileRepository>().activeProfile;
    if (profile == null) return;

    final progress = await context
        .read<ProgressRepository>()
        .getWorldProgressById(profile.id!, world.id);

    if (progress != null && !progress.isUnlocked) {
      context.read<NarrationService>().speak(
            'Keep exploring to unlock ${world.name}!',
          );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WorldDetailScreen(world: world),
        transitionsBuilder: (_, animation, __, child) =>
            ScaleTransition(scale: animation, child: child),
        transitionDuration: AppConstants.transitionDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFB2EBF2),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Buddy icon
                    GestureDetector(
                      onTap: () {
                        // TODO: Open buddy customization
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.buddyBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          color: AppColors.buddyBlue,
                          size: 28,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      'Adventure Buddies',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.buddyBlue,
                                fontSize: 20,
                              ),
                    ),
                    const Spacer(),
                    // Parent dashboard button
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, '/parent_dashboard'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.dashboard_rounded,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        // Accessibility
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // World list headline
              Text(
                'Choose a World!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                    ),
              ),

              const SizedBox(height: 24),

              // World cards carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: World.allWorlds.length,
                  itemBuilder: (context, index) {
                    final world = World.allWorlds[index];
                    final isCenter = index == _currentPage;
                    return GestureDetector(
                      onTap: () => _onWorldTap(world),
                      onLongPress: () => _onWorldTap(world),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: isCenter ? 0 : 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              world.primaryColor,
                              world.secondaryColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: world.primaryColor.withOpacity(
                                  isCenter ? 0.4 : 0.2),
                              blurRadius: isCenter ? 20 : 10,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // World icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  world.icon,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                world.name,
                                style: const TextStyle(
                                  fontFamily: 'FredokaOne',
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                world.subtitle,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                world.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${world.activities.length} Activities',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page indicator dots
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(World.allWorlds.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.buddyBlue
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}