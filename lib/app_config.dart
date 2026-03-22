class AppConfig {
  static const String gitCommit = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: 'dev',
  );
}
