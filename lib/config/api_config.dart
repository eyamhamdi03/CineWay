import 'dart:io';

class ApiConfig {
  /// Get the base API URL based on platform
  /// On Android emulator: 10.0.2.2
  /// On iOS emulator & web: localhost
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      return 'http://localhost:8000/api/v1';
    }
  }
}
