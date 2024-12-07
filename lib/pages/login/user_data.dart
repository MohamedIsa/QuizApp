class UserData {
  static String email = '';
  static String name = '';
  static String role = '';

  static void setUserData(String userEmail, String userName, String userRole) {
    email = userEmail;
    name = userName;
    role = userRole;
  }

  static void clearUserData() {
    email = '';
    name = '';
    role = '';
  }
}
