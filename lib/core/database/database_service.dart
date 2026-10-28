import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Cross-platform Database Service for Neon PostgreSQL.
/// Uses Neon Serverless HTTP SQL API (`POST /sql`), allowing seamless execution
/// across Flutter Web (Microsoft Edge, Google Chrome) and Native Desktop / Mobile
/// without raw TCP socket limitations or 64-bit integer JS compilation conflicts.
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  final http.Client _client = http.Client();

  DatabaseService._();

  String _env(String key, [String fallback = '']) {
    try {
      return dotenv.isInitialized ? (dotenv.env[key] ?? fallback) : fallback;
    } catch (_) {
      return fallback;
    }
  }

  // Credentials are ONLY read from .env — never hardcode secrets in source.
  String get host => _env('DB_HOST');
  int get port => int.tryParse(_env('DB_PORT', '5432')) ?? 5432;
  String get database => _env('DB_NAME', 'neondb');
  String get username => _env('DB_USER');
  String get password => _env('DB_PASSWORD');

  /// True when the Neon connection is configured via .env.
  bool get isConfigured =>
      host.isNotEmpty &&
      username.isNotEmpty &&
      password.isNotEmpty &&
      password != 'your_password_here';

  /// Helper to safely replace positional parameters ($1, $2, ...) with properly escaped SQL literals.
  String _formatQuery(String sql, List<Object?> parameters) {
    var formatted = sql;
    for (int i = 0; i < parameters.length; i++) {
      final placeholder = '\$${i + 1}';
      final val = parameters[i];
      final String sqlVal;
      if (val == null) {
        sqlVal = 'NULL';
      } else if (val is num) {
        sqlVal = val.toString();
      } else if (val is bool) {
        sqlVal = val ? 'TRUE' : 'FALSE';
      } else if (val is DateTime) {
        sqlVal = "'${val.toIso8601String()}'";
      } else {
        sqlVal = "'${val.toString().replaceAll("'", "''")}'";
      }
      formatted = formatted.replaceAllMapped(
        RegExp(RegExp.escape(placeholder) + r'(?!\d)'),
        (_) => sqlVal,
      );
    }
    return formatted;
  }

  /// Executes a query with automatic retry on transient network drops
  Future<List<List<dynamic>>> query(
    String sql, {
    List<Object?>? parameters,
    int maxRetries = 2,
  }) async {
    if (!isConfigured) {
      throw StateError('Database not configured. Fill DB_* values in .env');
    }

    final queryToRun = (parameters != null && parameters.isNotEmpty)
        ? _formatQuery(sql, parameters)
        : sql;

    final url = Uri.parse('https://$host/sql');
    final connectionString =
        'postgresql://$username:$password@$host/$database?sslmode=require';

    int attempts = 0;
    while (true) {
      try {
        final response = await _client
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Neon-Connection-String': connectionString,
                'Neon-Array-Mode': 'true',
              },
              body: jsonEncode({'query': queryToRun}),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('rows') && data['rows'] is List) {
            final rawRows = data['rows'] as List;
            return rawRows
                .map((r) => r is List ? List<dynamic>.from(r) : <dynamic>[r])
                .toList();
          }
          return <List<dynamic>>[];
        } else {
          final errorBody = response.body;
          throw Exception(
            'Neon HTTP query failed (${response.statusCode}): $errorBody',
          );
        }
      } catch (e) {
        attempts++;
        if (attempts > maxRetries || e is StateError) {
          rethrow;
        }
        // Exponential backoff: 1s, 2s, 4s (ARCHITECTURE.md §4)
        await Future.delayed(Duration(seconds: 1 << (attempts - 1)));
      }
    }
  }

  /// Executes parameterized SQL statements with positional substitutions
  Future<List<List<dynamic>>> executeParams(
    String sql,
    List<Object?> parameters, {
    int maxRetries = 2,
  }) async {
    return query(sql, parameters: parameters, maxRetries: maxRetries);
  }

  Future<void> close() async {
    _client.close();
  }
}
