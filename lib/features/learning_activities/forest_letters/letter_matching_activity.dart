import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/audio_service.dart';
import '../activity_template_screen.dart';

class LetterMatchingActivity extends StatefulWidget {
  const LetterMatchingActivity({super.key});

  @override
  State<LetterMatchingActivity> createState() => _LetterMatchingActivityState();
}

class _LetterMatchingActivityState extends State<LetterMatchingActivity>
    with TickerProviderStateMixin {
  static const List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  static const List<String> _images = [
    'apple', 'book', 'cat', 'dog', 'egg', 'fish', 'grapes', 'hat',
    'igloo', 'juice', 'kite', 'lion', 'moon', 'nest', 'octopus', 'pizza',
    'queen', 'rainbow', 'sun', 'tree', 'umbrella', 'violin', 'watermelon',
    'xylophone', 'yarn', 'zebra',
  ];

  late List<_LetterRound> _rounds;
  int _currentRound = 0;
  int _stars = 0;
  int _correctInRound = 0;
  bool _isComplete = false;
  bool _isTransitioning = false;
  int? _selectedIndex;

  late AnimationController _starAnimController;
  late AnimationController _shakeController;
  late Animation<double> _starScale;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _starAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _starScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starAnimController, curve: Curves.elasticOut),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _rounds = _generateRounds();
    _announceRound();
  }

  List<_LetterRound> _generateRounds() {
    final random = Random();
    final selected = <String>[..._letters]..shuffle(random);
    final rounds = <_LetterRound>[];

    for (int i = 0; i < 5; i++) {
      final targetLetter = selected[i];
      // Pick 2-3 distractors
      final distractors = <String>[..._letters]
        ..remove(targetLetter)
        ..shuffle(random);
      final options = [targetLetter, ...distractors.take(3)]
        ..shuffle(random);
      rounds.add(_LetterRound(
        targetLetter: targetLetter,
        options: options,
        imageHint: _images[_letters.indexOf(targetLetter)],
      ));
    }
    return rounds;
  }

  void _announceRound() {
    if (_currentRound >= _rounds.length) return;
    final round = _rounds[_currentRound];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NarrationService>().speak(
            'Find the letter ${round.targetLetter}!',
          );
    });
  }

  void _onLetterTap(int index) {
    if (_isTransitioning || _isComplete) return;

    final round = _rounds[_currentRound];
    setState(() => _selectedIndex = index);

    if (round.options[index] == round.targetLetter) {
      // Correct!
      context.read<AudioService>().playCorrectAction();
      _correctInRound++;
      _starAnimController.forward(from: 0.0);

      setState(() {
        _stars = (_stars + 1).clamp(0, 3);
      });

      context.read<NarrationService>().sayCorrect();

      _isTransitioning = true;
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        if (_currentRound + 1 >= _rounds.length || _stars >= 3) {
          setState(() {
            _isComplete = true;
          });
          context.read<AudioService>().playRewardJingle();
          context.read<NarrationService>().sayComplete();
        } else {
          setState(() {
            _currentRound++;
            _selectedIndex = null;
            _isTransitioning = false;
          });
          _announceRound();
        }
      });
    } else {
      // Wrong
      context.read<AudioService>().playGentleError();
      _shakeController.forward(from: 0.0);
      context.read<NarrationService>().speak(
            "That's not ${round.targetLetter}. Try again!",
          );
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _selectedIndex = null);
      });
    }
  }

  @override
  void dispose() {
    _starAnimController.dispose();
    _shakeController.dispose();
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
              AppColors.forestGreen,
              AppColors.paleLeaf,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with stars and navigation
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

              // Image hint
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded,
                        size: 36, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(height: 4),
                    Text(
                      round.targetLetter,
                      style: const TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Instruction
              Text(
                _isComplete
                    ? 'Amazing! 🌟'
                    : 'Find the letter ${round.targetLetter}!',
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Letter options grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _isComplete
                      ? _buildCompleteScreen()
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(round.options.length,
                                    (index) {
                                  return _buildLetterTile(
                                    round.options[index],
                                    index,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterTile(String letter, int index) {
    final isSelected = _selectedIndex == index;
    final isCorrect = isSelected && letter == _rounds[_currentRound].targetLetter;
    final isWrong = isSelected && letter != _rounds[_currentRound].targetLetter;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            isWrong ? _shakeAnim.value : 0,
            0,
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _onLetterTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.successGreen
                : isWrong
                    ? AppColors.errorRed.withOpacity(0.3)
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                color: AppColors.forestGreen.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 48,
                color: isCorrect
                    ? Colors.white
                    : isWrong
                        ? AppColors.errorRed
                        : AppColors.forestGreen,
              ),
            ),
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
            Icons.celebration_rounded,
            size: 80,
            color: AppColors.sunnyYellow,
          ),
          const SizedBox(height: 16),
          const Text(
            'You found all the letters!',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collect your Letter Leaves reward! 🍃',
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
                backgroundColor: AppColors.leafyGreen,
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
}

class _LetterRound {
  final String targetLetter;
  final List<String> options;
  final String imageHint;

  const _LetterRound({
    required this.targetLetter,
    required this.options,
    required this.imageHint,
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