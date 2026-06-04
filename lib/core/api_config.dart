import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.get('INSFORGE_URL', fallback: 'https://f3k6x5hq.ap-southeast.insforge.app');

  static String get anonKey => dotenv.get('INSFORGE_ANON_KEY');

  static String get restUrl => '$baseUrl/rest/v1';
  static String get storageUrl => '$baseUrl/storage/v1';
  static String get functionsUrl => '$baseUrl/functions';
}
