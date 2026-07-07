import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../screens/dashboard_screen.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen>
    with SingleTickerProviderStateMixin {
  double _holdProgress = 0.0;
  bool _isHolding = false;
  bool _passed = false;

  void _onTapDown(TapDownDetails details) {
    if (_passed) return;
    setState(() => _isHolding = true);
    _startHoldTimer();
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isHolding) return;
    setState(() => _isHolding = false);
    _holdProgress = 0.0;
  }

  void _onTapCancel() {
    if (!_isHolding) return;
    setState(() => _isHolding = false);
    _holdProgress = 0.0;
  }

  void _startHoldTimer() {
    const duration = Duration(milliseconds: 3000);
    const interval = Duration(milliseconds: 30);
    int elapsed = 0;
    final totalSteps = duration.inMilliseconds ~/ interval.inMilliseconds;

    Future.doWhile(() async {
      if (!_isHolding || _passed) return false;
      await Future.delayed(interval);
      elapsed++;
      if (mounted) {
        setState(() {
          _holdProgress = elapsed / totalSteps;
        });
      }
      if (_holdProgress >= 1.0) {
        _passed = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Parents Only',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This area is for grown-ups',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 40),

              // Hold button
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _holdProgress >= 1.0
                        ? AppColors.leafyGreen
                        : AppColors.buddyBlue.withOpacity(0.1),
                    border: Border.all(
                      color: _holdProgress >= 1.0
                          ? AppColors.leafyGreen
                          : AppColors.buddyBlue,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _holdProgress >= 1.0
                              ? Icons.check_rounded
                              : Icons.touch_app_rounded,
                          size: 48,
                          color: _holdProgress >= 1.0
                              ? AppColors.leafyGreen
                              : AppColors.buddyBlue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hold for 3s',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.bold,
                            color: _holdProgress >= 1.0
                                ? AppColors.leafyGreen
                                : AppColors.buddyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _holdProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _holdProgress >= 1.0
                        ? AppColors.leafyGreen
                        : AppColors.buddyBlue,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Game',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}