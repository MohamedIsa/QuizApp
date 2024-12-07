// user_data.dart

class UserData {
  static String email = '';
  static String name = '';
  static String role = '';

  // Optionally, you can create a method to set the user data
  static void setUserData(String userEmail, String userName, String userRole) {
    email = userEmail;
    name = userName;
    role = userRole;
  }

  // Optionally, you can create a method to clear the user data when logging out
  static void clearUserData() {
    email = '';
    name = '';
    role = '';
  }
}
