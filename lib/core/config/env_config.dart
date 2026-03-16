enum Environment { dev, staging, production }

class EnvConfig {
  final Environment environment;
  final String baseUrl;
  final String wsUrl;
  final String googleMapsKey;
  final bool enableLogs;
  final bool enableCrashlytics;

  const EnvConfig._({
    required this.environment,
    required this.baseUrl,
    required this.wsUrl,
    required this.googleMapsKey,
    this.enableLogs = false,
    this.enableCrashlytics = false,
  });

  static const dev = EnvConfig._(
    environment: Environment.dev,
    baseUrl: 'http://192.168.1.100:3000/api/v1',
    wsUrl: 'ws://192.168.1.100:3000',
    googleMapsKey: 'YOUR_DEV_MAPS_KEY',
    enableLogs: true,
    enableCrashlytics: false,
  );

  static const staging = EnvConfig._(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.wajba.dz/api/v1',
    wsUrl: 'wss://staging-api.wajba.dz',
    googleMapsKey: 'YOUR_STAGING_MAPS_KEY',
    enableLogs: true,
    enableCrashlytics: true,
  );

  static const production = EnvConfig._(
    environment: Environment.production,
    baseUrl: 'https://api.wajba.dz/api/v1',
    wsUrl: 'wss://api.wajba.dz',
    googleMapsKey: 'YOUR_PROD_MAPS_KEY',
    enableLogs: false,
    enableCrashlytics: true,
  );

  bool get isDev => environment == Environment.dev;
  bool get isProduction => environment == Environment.production;
  String get name => environment.name.toUpperCase();
}

// ── Active config (change for each build target) ──
// Use: flutter run --dart-define=ENV=dev
EnvConfig getEnvConfig() {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  switch (env) {
    case 'staging': return EnvConfig.staging;
    case 'production': return EnvConfig.production;
    default: return EnvConfig.dev;
  }
}

final envConfig = getEnvConfig();
