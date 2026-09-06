class AppConfig {
  static const String appName = 'لفظ';
  static const String appNameEnglish = 'Lafz';
  static const String appSubtitle = 'روز کا لفظ';
  static const String appVersion = '1.1.3';

  /// Remote daily-puzzle endpoint. Empty = disabled (bundled list only).
  /// When set, expected response: {"word": "...", "id": "..."}.
  /// Any failure falls back to the bundled word list.
  static const String remotePuzzleUrl = '';
}
