class AppConstants {
  static const String appName = 'Adventure Buddies';
  static const String appSubtitle = 'Learn & Play';

  // Sizes
  static const double minTapTarget = 64.0;
  static const double buttonMinWidth = 200.0;
  static const double iconSizeSmall = 32.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeLarge = 64.0;

  // Animation
  static const Duration transitionDuration = Duration(milliseconds: 500);
  static const Duration buttonAnimationDuration = Duration(milliseconds: 200);
  static const Duration rewardAnimationDuration = Duration(seconds: 2);

  // Real World Mission
  static const int activitiesBeforeMission = 3;
  static const int minMissionDuration = 5;
  static const int maxMissionDuration = 15;

  // Parent Gate
  static const int parentGateHoldDuration = 3;

  // Database
  static const String databaseName = 'adventure_buddies.db';
  static const int databaseVersion = 1;

  // Numbers
  static const int maxStarsPerActivity = 3;
  static const int totalWorlds = 4;
  static const int maxActivitiesPerWorld = 5;
  static const int buddyCustomizationSlots = 6;
}