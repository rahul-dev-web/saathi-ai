class AppConstants {
  // API
  static const String apiBaseUrl = 'https://saathi-ai-0ck4.onrender.com/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // App
  static const String appName = 'SAATHI AI';
  static const String appVersion = '1.0.0';
}

class AppStrings {
  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Name';
  static const String confirmPassword = 'Confirm Password';
  
  // Buttons
  static const String next = 'Next';
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  
  // Messages
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String success = 'Success!';
  
  // Settings
  static const String settings = 'Settings';
  static const String theme = 'Theme';
  static const String language = 'Language';
  static const String notifications = 'Notifications';
}

class AppSizes {
  static const double paddingXs = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXl = 32.0;
  
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
}