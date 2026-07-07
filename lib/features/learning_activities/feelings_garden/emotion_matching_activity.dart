import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/audio_service.dart';

class EmotionMatchingActivity extends StatefulWidget {
  const EmotionMatchingActivity({super.key});

  @override
  State<EmotionMatchingActivity> createState() =>
      _EmotionMatchingActivityState();
}

class _EmotionMatchingActivityState extends State<EmotionMatchingActivity>
    with TickerProviderStateMixin {
  static const int _roundsCount = 5;

  late final List<_EmotionRound> _rounds;
  int _currentRound = 0;
  int _stars = 0;
  int? _selectedEmotion;
  bool _isComplete = false;
  bool _isTransitioning = false;

  late AnimationController _bloomController;
  late Animation<double> _bloomScale;
  late AnimationController _starAnimController;
  late Animation<double> _starScale;

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bloomScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bloomController, curve: Curves.elasticOut),
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

  List<_EmotionRound> _generateRounds() {
    final random = Random();
    final emotions = _allEmotions.toList()..shuffle(random);
    final gardenFriends = [
      ('Bunny', Icons.face_4_rounded),
      ('Bear', Icons.face_2_rounded),
      ('Fox', Icons.face_3_rounded),
      ('Kitty', Icons.face_5_rounded),
      ('Puppy', Icons.pets_rounded),
    ];

    final rounds = <_EmotionRound>[];
    for (int i = 0; i < _roundsCount; i++) {
      final target = emotions[i % emotions.length];
      final distractors = _allEmotions
          .where((e) => e.emotion != target.emotion)
          .toList()
        ..shuffle(random);
      final options = [target, ...distractors.take(3)]..shuffle(random);
      rounds.add(_EmotionRound(
        targetEmotion: target,
        options: options,
        friendName: gardenFriends[i % gardenFriends.length].$1,
        friendIcon: gardenFriends[i % gardenFriends.length].$2,
      ));
    }
    return rounds;
  }

  void _announceRound() {
    if (_currentRound >= _rounds.length) return;
    final round = _rounds[_currentRound];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NarrationService>().speak(
            'How does ${round.friendName} feel?',
          );
    });
  }

  void _onEmotionTap(int index) {
    if (_isTransitioning || _isComplete) return;

    final round = _rounds[_currentRound];
    setState(() => _selectedEmotion = index);

    if (round.options[index].emotion == round.targetEmotion.emotion) {
      context.read<AudioService>().playCorrectAction();
      _bloomController.forward(from: 0.0);
      _starAnimController.forward(from: 0.0);
      setState(() => _stars = (_stars + 1).clamp(0, 3));
      context.read<NarrationService>().speak(
            'Yes! ${round.friendName} is ${round.targetEmotion.emotion}!',
          );

      _isTransitioning = true;
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        if (_currentRound + 1 >= _rounds.length || _stars >= 3) {
          setState(() {
            _isComplete = true;
            _selectedEmotion = null;
          });
          context.read<AudioService>().playRewardJingle();
          context.read<NarrationService>().sayComplete();
        } else {
          setState(() {
            _currentRound++;
            _selectedEmotion = null;
            _isTransitioning = false;
          });
          _announceRound();
        }
      });
    } else {
      context.read<AudioService>().playGentleError();
      context.read<NarrationService>().speak(
            "Hmm, that's not it. Let's look at ${round.friendName}'s face again!",
          );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _selectedEmotion = null);
      });
    }
  }

  @override
  void dispose() {
    _bloomController.dispose();
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
              AppColors.lavender,
              AppColors.softRose,
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
                    Row(
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _starAnimController,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: i < _stars && i == _stars - 1
                                    ? _starScale.value
                                    : 1.0,
                                child: Icon(
                                  i < _stars
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
                _isComplete
                    ? 'Kind Heart! 🌸'
                    : 'How does ${round.friendName} feel?',
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Garden friend display
              Expanded(
                flex: 3,
                child: _isComplete
                    ? _buildCompleteScreen()
                    : Column(
                        children: [
                          ScaleTransition(
                            scale: _bloomScale,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    round.friendIcon,
                                    size: 56,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    round.targetEmotion.emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            round.targetEmotion.emotion,
                            style: const TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),

              // Emotion options
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _isComplete
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Text(
                              'How do they feel?',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(
                                    round.options.length, (index) {
                                  return _buildEmotionTile(
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

  Widget _buildEmotionTile(_EmotionOption emotion, int index) {
    final isSelected = _selectedEmotion == index;
    final isCorrect =
        isSelected && emotion.emotion == _rounds[_currentRound].targetEmotion.emotion;
    final isWrong =
        isSelected && emotion.emotion != _rounds[_currentRound].targetEmotion.emotion;

    return GestureDetector(
      onTap: () => _onEmotionTap(index),
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
              color: AppColors.lavender.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emotion.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 4),
            Text(
              emotion.emotion,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCorrect
                    ? Colors.white
                    : isWrong
                        ? AppColors.errorRed
                        : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_florist_rounded,
              size: 80, color: AppColors.sunnyYellow),
          const SizedBox(height: 16),
          const Text(
            'You\'re so kind!',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collect your Kindness Flower! 🌷',
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
                backgroundColor: AppColors.lavender,
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

class _EmotionOption {
  final String emotion;
  final String emoji;

  const _EmotionOption({required this.emotion, required this.emoji});
}

const List<_EmotionOption> _allEmotions = [
  _EmotionOption(emotion: 'Happy', emoji: '😊'),
  _EmotionOption(emotion: 'Sad', emoji: '😢'),
  _EmotionOption(emotion: 'Surprised', emoji: '😮'),
  _EmotionOption(emotion: 'Sleepy', emoji: '😴'),
  _EmotionOption(emotion: 'Silly', emoji: '😜'),
  _EmotionOption(emotion: 'Loving', emoji: '🥰'),
];

class _EmotionRound {
  final _EmotionOption targetEmotion;
  final List<_EmotionOption> options;
  final String friendName;
  final IconData friendIcon;

  const _EmotionRound({
    required this.targetEmotion,
    required this.options,
    required this.friendName,
    required this.friendIcon,
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