/// Supported application locales
enum AppLocale {
  english('en', 'English'),
  french('fr', 'Français');

  final String code;
  final String displayName;

  const AppLocale(this.code, this.displayName);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (locale) => locale.code == code,
      orElse: () => AppLocale.english,
    );
  }
}
