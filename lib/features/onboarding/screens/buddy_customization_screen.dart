import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../world_map/screens/world_map_screen.dart';

class BuddyCustomizationScreen extends StatefulWidget {
  final String childName;

  const BuddyCustomizationScreen({super.key, required this.childName});

  @override
  State<BuddyCustomizationScreen> createState() =>
      _BuddyCustomizationScreenState();
}

class _BuddyCustomizationScreenState extends State<BuddyCustomizationScreen> {
  static const List<Color> _buddyColors = [
    Color(0xFFF0C080), // Golden
    Color(0xFFD4A574), // Brown
    Color(0xFFFFFFFF), // White
    Color(0xFFB0B0B0), // Grey
    Color(0xFFFF8A65), // Orange
    Color(0xFF81D4FA), // Light Blue
  ];

  static const List<Map<String, dynamic>> _types = [
    {'id': 'fox', 'icon': Icons.face_3, 'label': 'Fox'},
    {'id': 'bear', 'icon': Icons.face_2, 'label': 'Bear'},
    {'id': 'bunny', 'icon': Icons.face_4, 'label': 'Bunny'},
    {'id': 'cat', 'icon': Icons.face_5, 'label': 'Cat'},
  ];

  static const List<String> _hats = [
    'none', 'crown', 'party', 'captain',
  ];

  int _selectedType = 0;
  int _selectedColor = 0;
  int _selectedHat = 0;
  bool _isCreating = false;

  void _onFinish() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final repo = context.read<ProfileRepository>();
      final storage = await StorageService.getInstance();

      final profile = await repo.createProfile(
        name: widget.childName,
        buddyType: _types[_selectedType]['id'] as String,
        buddyColor: '#${_buddyColors[_selectedColor].value.toRadixString(16).padLeft(8, '0').substring(2)}',
        buddyHat: _hats[_selectedHat],
      );

      await storage.setOnboardingCompleted(true);
      await storage.setActiveProfileId(profile.id!);

      context.read<NarrationService>().speak(
            'Great choice! Let\'s go on an adventure!',
          );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WorldMapScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Title
            Text(
              'Meet Your Buddy!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how they look',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const Spacer(flex: 1),

            // Buddy preview
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _buddyColors[_selectedColor].withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _buddyColors[_selectedColor],
                  width: 4,
                ),
              ),
              child: Icon(
                _types[_selectedType]['icon'] as IconData,
                size: 70,
                color: _buddyColors[_selectedColor],
              ),
            ),

            const SizedBox(height: 24),

            // Type selector
            _buildSectionLabel('Choose your buddy'),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedType;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buddyBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.buddyBlue
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _types[index]['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _types[index]['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Color selector
            _buildSectionLabel('Pick a color'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_buddyColors.length, (index) {
                final isSelected = index == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isSelected ? 52 : 40,
                    height: isSelected ? 52 : 40,
                    decoration: BoxDecoration(
                      color: _buddyColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.buddyBlue
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.buddyBlue.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Hat selector
            _buildSectionLabel('Pick a hat'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _hatOption(0, Icons.emoji_people, 'None'),
                const SizedBox(width: 12),
                _hatOption(1, Icons.workspace_premium, 'Crown'),
                const SizedBox(width: 12),
                _hatOption(2, Icons.celebration, 'Party'),
                const SizedBox(width: 12),
                _hatOption(3, Icons.flight, 'Captain'),
              ],
            ),

            const Spacer(flex: 2),

            // Finish button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.leafyGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.leafyGreen.withOpacity(0.4),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Start Adventure!',
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
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  Widget _hatOption(int index, IconData icon, String label) {
    final isSelected = index == _selectedHat;
    return GestureDetector(
      onTap: () => setState(() => _selectedHat = index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 60 : 50,
            height: isSelected ? 60 : 50,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.playfulPink : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.playfulPink
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColors.playfulPink
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}