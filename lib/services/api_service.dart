import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  // Base URL for your API
  final String baseUrl = 'http://localhost:8000/api';
  
  // Authentication token storage
  String? _authToken;
  
  // Headers for requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // Login user
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token']; // Store token for authenticated requests
        return data;
      } else {
        print('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  // Register user
  Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }
  
  // Get users list
  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        print('Failed to load users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Get users error: $e');
      return [];
    }
  }
  
  // Create user
  Future<bool> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Create user error: $e');
      return false;
    }
  }
  
  // Update user
  Future<bool> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }
  
  // Delete user
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Delete user error: $e');
      return false;
    }
  }
}