import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/audio_service.dart';

class ShapeBuildingActivity extends StatefulWidget {
  const ShapeBuildingActivity({super.key});

  @override
  State<ShapeBuildingActivity> createState() => _ShapeBuildingActivityState();
}

class _ShapeBuildingActivityState extends State<ShapeBuildingActivity>
    with TickerProviderStateMixin {
  static const int _roundsCount = 4;

  late List<_HouseRound> _rounds;
  int _currentRound = 0;
  int _stars = 0;
  final Map<String, bool> _placed = {};
  bool _isComplete = false;
  bool _roundComplete = false;
  String? _draggingShape;

  late AnimationController _starAnimController;
  late Animation<double> _starScale;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnim;

  @override
  void initState() {
    super.initState();
    _starAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _starScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starAnimController, curve: Curves.elasticOut),
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _celebrationAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _rounds = _generateRounds();
    _initRound();
    _announceRound();
  }

  List<_HouseRound> _generateRounds() {
    final random = Random();
    final colors = [
      [const Color(0xFFFF6B6B), const Color(0xFFFFD93D)], // Red house, yellow roof
      [const Color(0xFF6BCB77), const Color(0xFF4D96FF)], // Green house, blue roof
      [const Color(0xFF9B59B6), const Color(0xFFFF8A65)], // Purple house, orange roof
      [const Color(0xFF00BCD4), const Color(0xFFFFEB3B)], // Cyan house, yellow roof
    ];

    return List.generate(_roundsCount, (i) {
      return _HouseRound(
        houseColor: colors[i][0],
        roofColor: colors[i][1],
      );
    });
  }

  void _initRound() {
    _placed.clear();
    _roundComplete = false;
    _draggingShape = null;
  }

  void _announceRound() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NarrationService>().speak(
            'Build a house! Drag the shapes into place!',
          );
    });
  }

  void _onShapeDragStart(String shape) {
    setState(() => _draggingShape = shape);
  }

  void _onShapeDropped(String shape, String targetSlot) {
    if (_placed[shape] == true || _roundComplete) return;

    if (shape == targetSlot) {
      setState(() {
        _placed[shape] = true;
        _draggingShape = null;
      });
      context.read<AudioService>().playCorrectAction();

      // Check if round complete
      if (_placed.length >= 2) {
        _onRoundComplete();
      }
    } else {
      context.read<AudioService>().playGentleError();
      setState(() => _draggingShape = null);
      context.read<NarrationService>().speak('Try a different spot!');
    }
  }

  void _onRoundComplete() {
    setState(() => _roundComplete = true);
    context.read<AudioService>().playRewardJingle();
    _starAnimController.forward(from: 0.0);
    setState(() => _stars = (_stars + 1).clamp(0, 3));
    context.read<NarrationService>().sayCorrect();
    _celebrationController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentRound + 1 >= _rounds.length || _stars >= 3) {
        setState(() => _isComplete = true);
        context.read<NarrationService>().sayComplete();
      } else {
        setState(() {
          _currentRound++;
          _roundComplete = false;
        });
        _initRound();
        _announceRound();
      }
    });
  }

  @override
  void dispose() {
    _starAnimController.dispose();
    _celebrationController.dispose();
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
              AppColors.royalPurple,
              AppColors.skyBlue,
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

              const SizedBox(height: 12),

              // Instruction
              Text(
                _isComplete
                    ? 'Great Builder! 🌟'
                    : _roundComplete
                        ? 'House Complete! 🏠'
                        : 'Build the House!',
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // House building area
              Expanded(
                flex: 4,
                child: _isComplete
                    ? _buildCompleteScreen()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // House outline / drop targets
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Roof drop zone (triangle)
                                      _DropTargetSlot(
                                        shape: 'roof',
                                        isPlaced: _placed['roof'] == true,
                                        placedColor: round.roofColor,
                                        hint: '△',
                                        onDrop: (shape) =>
                                            _onShapeDropped(shape, 'roof'),
                                      ),
                                      const SizedBox(height: 8),
                                      // Square drop zone
                                      _DropTargetSlot(
                                        shape: 'square',
                                        isPlaced: _placed['square'] == true,
                                        placedColor: round.houseColor,
                                        hint: '▢',
                                        onDrop: (shape) =>
                                            _onShapeDropped(shape, 'square'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Draggable shapes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _DraggableShape(
                                  shape: 'square',
                                  color: round.houseColor,
                                  isPlaced: _placed['square'] == true,
                                  onDragStart: () => _onShapeDragStart('square'),
                                ),
                                const SizedBox(width: 32),
                                _DraggableShape(
                                  shape: 'roof',
                                  color: round.roofColor,
                                  isPlaced: _placed['roof'] == true,
                                  onDragStart: () => _onShapeDragStart('roof'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drag shapes to the house',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
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

  Widget _buildCompleteScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_city_rounded,
              size: 80, color: AppColors.sunnyYellow),
          const SizedBox(height: 16),
          const Text(
            'You built all the houses!',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collect your Builder Badge! 🏆',
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
                backgroundColor: AppColors.royalPurple,
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

class _DropTargetSlot extends StatefulWidget {
  final String shape;
  final bool isPlaced;
  final Color placedColor;
  final String hint;
  final Function(String) onDrop;

  const _DropTargetSlot({
    required this.shape,
    required this.isPlaced,
    required this.placedColor,
    required this.hint,
    required this.onDrop,
  });

  @override
  State<_DropTargetSlot> createState() => _DropTargetSlotState();
}

class _DropTargetSlotState extends State<_DropTargetSlot> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (_) => setState(() => _isHovering = false),
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        widget.onDrop(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isAccepting = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.shape == 'roof' ? 120 : 100,
          height: widget.shape == 'roof' ? 60 : 80,
          decoration: BoxDecoration(
            color: widget.isPlaced
                ? widget.placedColor
                : isAccepting
                    ? widget.placedColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.3),
            borderRadius: widget.shape == 'roof'
                ? const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  )
                : BorderRadius.circular(12),
            border: Border.all(
              color: widget.isPlaced
                  ? widget.placedColor
                  : isAccepting
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
              width: widget.isPlaced ? 0 : 2,
            ),
          ),
          child: Center(
            child: widget.isPlaced
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 36)
                : Text(
                    widget.hint,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _DraggableShape extends StatelessWidget {
  final String shape;
  final Color color;
  final bool isPlaced;
  final VoidCallback onDragStart;

  const _DraggableShape({
    required this.shape,
    required this.color,
    required this.isPlaced,
    required this.onDragStart,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPlaced ? 0.3 : 1.0,
      child: LongPressDraggable<String>(
        data: shape,
        onDragStarted: onDragStart,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 80,
            height: shape == 'roof' ? 50 : 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: shape == 'roof'
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )
                  : BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                shape == 'roof' ? Icons.change_history : Icons.square_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildShapeWidget(),
        ),
        child: _buildShapeWidget(),
      ),
    );
  }

  Widget _buildShapeWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 80,
      height: shape == 'roof' ? 50 : 70,
      decoration: BoxDecoration(
        color: color,
        borderRadius: shape == 'roof'
            ? const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )
            : BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          shape == 'roof' ? Icons.change_history : Icons.square_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

class _HouseRound {
  final Color houseColor;
  final Color roofColor;

  const _HouseRound({
    required this.houseColor,
    required this.roofColor,
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