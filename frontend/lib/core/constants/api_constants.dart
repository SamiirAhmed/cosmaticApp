import 'package:flutter/foundation.dart';

class ApiConstants {
  // 10.0.2.2 is the special IP that redirects to your computer's localhost from Android Emulator
  // Usage: http://10.0.2.2:8000/api
  // 10.0.2.2 for Android Emulator, 127.0.0.1 for Windows/iOS/Web
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000/api";
    }
    return "http://127.0.0.1:8000/api";
  }

  static String get uploadsUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/uploads";
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000/uploads";
    }
    return "http://127.0.0.1:8000/uploads";
  }
}
