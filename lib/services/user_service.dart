class UserService {
  static String? _currentUserEmail;

  static void setCurrentUserEmail(String email) {
    _currentUserEmail = email;
  }

  static String? get currentUserEmail => _currentUserEmail;

  static void clearUser() {
    _currentUserEmail = null;
  }
}

