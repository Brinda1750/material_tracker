import 'package:flutter/foundation.dart';
import 'package:smartfab_app/core/services/auth_service.dart';
import 'package:smartfab_app/core/services/service_locator.dart';
import 'package:smartfab_app/features/auth/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser != null && _authService.isAdmin(_currentUser!);
  bool get isOperator => _currentUser != null && _authService.isOperator(_currentUser!);
  
  AuthProvider() {
    _loadCurrentUser();
  }
  
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Error loading current user: $e');
    }
  }
  
  Future<void> signIn(String email, String password) async {
    try {
      _currentUser = await _authService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      await _authService.createUser(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    try {
      if (_currentUser == null) return;
      
      final updatedUser = _currentUser!.copyWith(
        name: name,
        photoUrl: photoUrl,
      );
      
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
