import 'package:flutter/foundation.dart';

class SessionController extends ChangeNotifier {
  SessionController._();

  static final SessionController instance = SessionController._();

  int _logoutVersion = 0;

  int get logoutVersion => _logoutVersion;

  void notifyForcedLogout() {
    _logoutVersion++;
    notifyListeners();
  }
}
