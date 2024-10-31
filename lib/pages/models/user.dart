// Original Users class remains unchanged for other parts of the app
class Users {
  String id;
  String name;
  String email;
  String role;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Users.fromFirestore(Map<String, dynamic> data, String id) {
    return Users(
      id: id,
      name: data['name'],
      email: data['email'],
      role: data['role'],
    );
  }
}
