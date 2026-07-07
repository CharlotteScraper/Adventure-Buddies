import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/audio_service.dart';

class CountSeashellsActivity extends StatefulWidget {
  const CountSeashellsActivity({super.key});

  @override
  State<CountSeashellsActivity> createState() => _CountSeashellsActivityState();
}

class _CountSeashellsActivityState extends State<CountSeashellsActivity>
    with TickerProviderStateMixin {
  static const int _roundsCount = 5;
  static const List<IconData> _shellIcons = [
    Icons.blur_on_rounded,
    Icons.circle_rounded,
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.water_drop_rounded,
  ];

  late List<_CountRound> _rounds;
  int _currentRound = 0;
  int _stars = 0;
  int? _selectedNumber;
  bool _isComplete = false;
  bool _isTransitioning = false;
  int? _correctAnswer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _starAnimController;
  late Animation<double> _starScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _starAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _starScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starAnimController, curve: Curves.elasticOut),
    );

    _rounds = _generateRounds();
    _announceRound();
  }

  List<_CountRound> _generateRounds() {
    final random = Random();
    final rounds = <_CountRound>[];
    final counts = <int>[];

    for (int i = 0; i < _roundsCount; i++) {
      int count;
      do {
        count = random.nextInt(5) + 1; // 1-5
      } while (counts.contains(count) && counts.length < 5);
      counts.add(count);

      final options = <int>{count};
      while (options.length < 4) {
        final distractor = random.nextInt(5) + 1;
        if (distractor != count) options.add(distractor);
      }

      rounds.add(_CountRound(
        shellCount: count,
        options: options.toList()..shuffle(random),
        shellIcon: _shellIcons[random.nextInt(_shellIcons.length)],
      ));
    }
    return rounds;
  }

  void _announceRound() {
    if (_currentRound >= _rounds.length) return;
    final round = _rounds[_currentRound];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NarrationService>().speak(
            'How many seashells do you see?',
          );
    });
  }

  void _onNumberTap(int number) {
    if (_isTransitioning || _isComplete) return;

    final round = _rounds[_currentRound];
    setState(() {
      _selectedNumber = number;
      _correctAnswer = round.shellCount;
    });

    if (number == round.shellCount) {
      context.read<AudioService>().playCorrectAction();
      _starAnimController.forward(from: 0.0);
      setState(() => _stars = (_stars + 1).clamp(0, 3));
      context.read<NarrationService>().speak('Yes! $number seashells!');

      _isTransitioning = true;
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        if (_currentRound + 1 >= _rounds.length || _stars >= 3) {
          setState(() {
            _isComplete = true;
            _selectedNumber = null;
          });
          context.read<AudioService>().playRewardJingle();
          context.read<NarrationService>().sayComplete();
        } else {
          setState(() {
            _currentRound++;
            _selectedNumber = null;
            _correctAnswer = null;
            _isTransitioning = false;
          });
          _announceRound();
        }
      });
    } else {
      context.read<AudioService>().playGentleError();
      context.read<NarrationService>().speak(
            "Let's count again! One, two, three...",
          );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _selectedNumber = null);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _starAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) return const SizedBox.shrink();
    final round = _rounds[_currentRound];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.oceanTurquoise,
              Color(0xFFB2EBF2),
              Color(0xFFFFF8E1),
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
                    Row(
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _starAnimController,
                            builder: (context, _) {
                              final showStar = i < _stars;
                              return Transform.scale(
                                scale: showStar && i == _stars - 1
                                    ? _starScale.value
                                    : 1.0,
                                child: Icon(
                                  showStar
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: AppColors.sunnyYellow,
                                  size: 36,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentRound + 1}/${_rounds.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Instruction
              Text(
                _isComplete ? 'Amazing Counting! 🌟' : 'Count the Seashells!',
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Seashell display
              Expanded(
                flex: 3,
                child: _isComplete
                    ? _buildCompleteScreen()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ScaleTransition(
                          scale: _pulseAnim,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(round.shellCount, (i) {
                              return Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _shellColors[i % _shellColors.length]
                                      .withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  round.shellIcon,
                                  size: 36,
                                  color: _shellColors[i % _shellColors.length],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
              ),

              // Number options
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'How many?',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(round.options.length, (index) {
                        final num = round.options[index];
                        final isSelected = _selectedNumber == num;
                        final isCorrect = isSelected && num == round.shellCount;
                        final isWrong =
                            isSelected && num != round.shellCount;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () => _onNumberTap(num),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 76 : 68,
                              height: isSelected ? 76 : 68,
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? AppColors.successGreen
                                    : isWrong
                                        ? AppColors.errorRed.withOpacity(0.3)
                                        : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCorrect
                                      ? AppColors.successGreen
                                      : isWrong
                                          ? AppColors.errorRed
                                          : Colors.white.withOpacity(0.5),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.oceanTurquoise
                                        .withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$num',
                                  style: TextStyle(
                                    fontFamily: 'FredokaOne',
                                    fontSize: isSelected ? 32 : 28,
                                    color: isCorrect
                                        ? Colors.white
                                        : isWrong
                                            ? AppColors.errorRed
                                            : AppColors.oceanTurquoise,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.beach_access_rounded,
            size: 80,
            color: AppColors.sunnyYellow,
          ),
          const SizedBox(height: 16),
          const Text(
            'You counted them all!',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collect your Starfish Token! ⭐',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 64,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coralOrange,
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
        ],
      ),
    );
  }

  static const List<Color> _shellColors = [
    AppColors.coralOrange,
    AppColors.sunnyYellow,
    AppColors.playfulPink,
    AppColors.buddyBlue,
    AppColors.leafyGreen,
  ];
}

class _CountRound {
  final int shellCount;
  final List<int> options;
  final IconData shellIcon;

  const _CountRound({
    required this.shellCount,
    required this.options,
    required this.shellIcon,
  });
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