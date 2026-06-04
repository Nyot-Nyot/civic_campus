import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.get('INSFORGE_URL', fallback: 'https://f3k6x5hq.ap-southeast.insforge.app');

  static String get anonKey =>
      dotenv.get('INSFORGE_ANON_KEY', fallback: 'test-anon-key');

  static String get restUrl => '$baseUrl/api/database/records';
  static String get storageUrl => '$baseUrl/api/storage';
  static String get functionsUrl => '$baseUrl/functions';
}
