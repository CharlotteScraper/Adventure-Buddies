import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/reward_repository.dart';
import 'data/repositories/mission_repository.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/parent_dashboard/screens/parent_gate_screen.dart';
import 'core/services/audio_service.dart';
import 'core/services/narration_service.dart';
import 'core/services/haptic_service.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.light,
  });

  final ThemeData theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => NarrationService()),
        ChangeNotifierProvider(create: (_) => HapticService()),
        ChangeNotifierProvider(create: (_) => DatabaseHelper()),
        ChangeNotifierProvider(create: (_) => ProfileRepository()),
        ChangeNotifierProvider(create: (_) => ProgressRepository()),
        ChangeNotifierProvider(create: (_) => RewardRepository()),
        ChangeNotifierProvider(create: (_) => MissionRepository()),
      ],
      child: MaterialApp(
        title: 'Adventure Buddies',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: const WelcomeScreen(),
        routes: {
          '/parent_dashboard': (context) => const ParentGateScreen(),
        },
      ),
    );
  }
}