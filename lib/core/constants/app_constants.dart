/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'ScrollBattle';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String friendsCollection = 'friends';
  static const String requestsCollection = 'requests';
  static const String dailyStatsCollection = 'daily_stats';
  static const String leaderboardCollection = 'leaderboard';
  static const String achievementsCollection = 'achievements';

  // Android package names
  static const String instagramPackage = 'com.instagram.android';
  static const String youtubePackage = 'com.google.android.youtube';

  // Thresholds
  static const int warningReelCount = 50;
  static const int dangerReelCount = 100;
  static const int warningShortsCount = 50;
  static const int dangerShortsCount = 100;

  // Addiction score weights
  static const double reelWeight = 1.0;
  static const double shortWeight = 1.0;
  static const double timeWeight = 0.5; // per minute

  // Shared prefs keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserId = 'user_id';
  static const String prefOverlayEnabled = 'overlay_enabled';
}
