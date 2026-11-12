// Anabhay Ventures — Restaurant Backend Configuration

import 'dart:io';

class AppConfig {
  final String serverName;
  final String companyName;
  final String version;
  final int port;
  final String dbHost;
  final int dbPort;
  final String dbUser;
  final String dbPassword;
  final String dbName;
  final bool dbSsl;

  const AppConfig({
    required this.serverName,
    required this.companyName,
    required this.version,
    required this.port,
    required this.dbHost,
    required this.dbPort,
    required this.dbUser,
    required this.dbPassword,
    required this.dbName,
    this.dbSsl = false,
  });

  factory AppConfig.fromEnvironment() {
    final env = Platform.environment;
    return AppConfig(
      serverName: 'Restaurant Management Backend',
      companyName: 'Anabhay Ventures',
      version: '1.0.0',
      port: int.tryParse(env['PORT'] ?? '8080') ?? 8080,
      dbHost: env['DB_HOST'] ?? 'localhost',
      dbPort: int.tryParse(env['DB_PORT'] ?? '5432') ?? 5432,
      dbUser: env['DB_USER'] ?? 'postgres',
      dbPassword: env['DB_PASSWORD'] ?? 'postgres',
      dbName: env['DB_NAME'] ?? 'restaurant_db',
      dbSsl: (env['DB_SSL'] ?? 'false').toLowerCase() == 'true',
    );
  }
}

