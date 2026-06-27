class AppConstants {
  AppConstants._();

  static const String appName = 'Memory Swipe';

  // Hive boxes (это названия "таблиц" в локальной базе данных)
  static const String trashBoxName = 'trash_box';
  static const String settingsBoxName = 'settings_box';
  static const String statisticsBoxName = 'statistics_box';
  static const String viewedPhotosBoxName = 'viewed_photos_box';
  static const String onboardingShownKey = 'onboarding_shown';

  // Сколько фото подгружать за один раз
  static const int photoPageSize = 20;

  // Сколько лет назад смотреть
  static const int yearsToLookBack = 10;
}