import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  final ApiService _apiService = ApiService();
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  
  // Login method
  Future<bool> login(String username, String password) async {
    try {
      final result = await _apiService.loginUser(username, password);
      
      print("Login API result: $result");
      
      if (result != null) {
        // Check if the response contains user information directly or in a nested object
        Map<String, dynamic> userData;
        
        if (result.containsKey('user')) {
          userData = result['user'];
        } else if (result.containsKey('data') && result['data'] is Map) {
          userData = result['data'];
        } else {
          // If no specific user key is found, try to parse the entire result as user data
          // Assuming it contains at least username and email
          if (result.containsKey('username') && result.containsKey('email')) {
            userData = result;
          } else {
            print("Failed to find user data in the response");
            return false;
          }
        }
        
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }
  
  // Register method
  Future<bool> register(User user) async {
    final result = await _apiService.registerUser(user);
    return result;
  }
  
  // Logout method
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
  
  // Check if user is authenticated
  bool checkAuthentication() {
    return _isAuthenticated && _currentUser != null;
  }
}