import 'dart:convert';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<User?> login(String email, String password) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/login');
    final Map<String, String> body = {'email': email, 'password': password};

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode(data['userData']));
        await prefs.setString('accessToken', data['accessToken']);

        // Lưu userId vào SharedPreferences
        final String userId = data['userData']['_id'];
        await prefs.setString('userId', userId);
        final String? currentUserJson = prefs.getString('currentUser');
        print('User Data: $data');
        print('Local Storage: $currentUserJson');
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Login failed: $error');
    }
  }

  static Future<User?> register(String firstname, String lastname, String email,
      String mobile, String password) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/register');
    final Map<String, String> body = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'mobile': mobile,
      'password': password
    };

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid firstname, lastname, mobile, email or password');
      } else {
        throw Exception('Register failed with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Register failed: $error');
    }
  }

  static Future<User?> verifyCode(
      String email, int confirmationCode, String password) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/register/verify');
    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'confirmationCode': confirmationCode
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Code verified successfully');
        return await login(email, password);
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw Exception('Code verification failed: ${data['mes']}');
      }
    } catch (error) {
      throw Exception('Failed to verify code: $error');
    }
  }

  static Future<User?> forgot_password(String email) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/forgotpassword');
    final Map<String, String> body = {
      'email': email,
    };

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email');
      } else {
        throw Exception('Email failed with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Email failed: $error');
    }
  }

  static Future<void> changePassword(
      String oldPassword, String newPassword) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/changepassword');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final Map<String, String> body = {
      'oldPassword': oldPassword,
      'newPassword': newPassword
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Password changed successfully');
      } else {
        throw Exception(
            'Failed to change password with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to change password: $error');
    }
  }

  static Future<User> updateUser(
      String userId, String firstname, String lastname, String mobile) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/updateuser/$userId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final Map<String, String> body = {
      'firstname': firstname,
      'lastname': lastname,
      'mobile': mobile,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('User info updated successfully');
        final Map<String, dynamic> responseData = json.decode(response.body);
        return User.fromJson(responseData['updatedUser']);
      } else {
        throw Exception(
            'Failed to update user info with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to update user info: $error');
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      return accessToken != null;
    } catch (error) {
      throw Exception('Failed to check if user is logged in: $error');
    }
  }

  static Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Logout successful');
    } catch (error) {
      throw Exception('Failed to logout: $error');
    }
  }

  static Future<User?> updateImage(String imagePath) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/updateimage');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'images': imagePath,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return User.fromJson(responseData['updatedImage']);
      } else {
        throw Exception(
            'Failed to update image with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to update image: $error');
    }
  }

  static Future<User?> getCurrent() async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/current');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return User.fromJson(responseData['user']);
      } else {
        throw Exception(
            'Failed to get current user with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to get current user: $error');
    }
  }

  static Future<List<User>> getUsers() async {
    final Uri url = Uri.parse('${Constants.uri}/api/user');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> usersData = responseData['users'] ?? [];
        List<User> users =
            usersData.map((data) => User.fromJson(data)).toList();
        return users;
      } else {
        throw Exception(
            'Failed to get users with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to get users: $error');
    }
  }

  static Future<User?> getUserById(String userId) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/$userId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return User.fromJson(responseData['user']);
      } else {
        throw Exception(
            'Failed to get user by ID with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to get user by ID: $error');
    }
  }

  Future<bool> addToTopicSaved(String topicId, String userId) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/$userId/$topicId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final Map<String, String> body = {
      'topicSaved': topicId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Topic added to saved list successfully');
        return true;
      } else {
        throw Exception(
            'Failed to add topic to saved list with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to add topic to saved list: $error');
    }
  }

  static Future<bool> deleteToSavedTopic(String topicId, String userId) async {
    final Uri url = Uri.parse('${Constants.uri}/api/user/$userId/$topicId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final Map<String, String> body = {
      'topicSaved': topicId,
    };

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Topic removed from saved list successfully');
        return true;
      } else {
        throw Exception(
            'Failed to remove topic from saved list with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to remove topic from saved list: $error');
    }
  }
}
