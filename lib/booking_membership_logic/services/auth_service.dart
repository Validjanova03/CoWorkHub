import 'package:coworkhub/database/db_helper.dart';

class AuthService {
  final DBHelper dbHelper = DBHelper();

  Future<String?> validateRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (firstName.isEmpty) return 'First name is required';
    if (lastName.isEmpty) return 'Last name is required';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (phone.isEmpty) return 'Phone number is required';
    if (phone.length < 8) return 'Phone number is too short';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';

    final users = await dbHelper.getUsers();
    final emailExists = users.any((user) => user['email'] == email);

    if (emailExists) return 'This email is already registered';

    return null;
  }

  Future<int> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await dbHelper.insertUser({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    return await dbHelper.loginUser(email, password);
  }
}