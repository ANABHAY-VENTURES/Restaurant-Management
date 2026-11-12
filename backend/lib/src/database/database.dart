// Anabhay Ventures — Database Connection Pool & Initialization

import 'package:postgres/postgres.dart';
import '../config/app_config.dart';

class DatabaseService {
  final AppConfig config;
  Pool<void>? _pool;

  DatabaseService(this.config);

  Future<void> initialize() async {
    try {
      final endpoint = Endpoint(
        host: config.dbHost,
        port: config.dbPort,
        database: config.dbName,
        username: config.dbUser,
        password: config.dbPassword,
      );

      _pool = Pool.withEndpoints(
        [endpoint],
        settings: PoolSettings(
          maxConnectionCount: 15,
          sslMode: config.dbSsl ? SslMode.require : SslMode.disable,
        ),
      );
    } catch (e) {
      // In development or when PostgreSQL container is starting up
      print('Database pool initialization note: $e');
    }
  }

  Future<bool> isHealthy() async {
    if (_pool == null) return false;
    try {
      final result = await _pool!.execute('SELECT 1');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> close() async {
    await _pool?.close();
  }
}

