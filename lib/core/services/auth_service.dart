import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartfab_app/core/services/firebase_service.dart';
import 'package:smartfab_app/core/services/local_storage_service.dart';
import 'package:smartfab_app/core/services/service_locator.dart';
import 'package:smartfab_app/features/auth/models/user_model.dart';

class AuthService {
  final FirebaseService _firebaseService = locator<FirebaseService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  
  Future<UserModel?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    // Try to get from local storage first
    UserModel? userModel = await _localStorageService.getUserById(user.uid);
    
    // If not found locally, try to get from Firebase
    if (userModel == null) {
      userModel = await _firebaseService.getUserProfile(user.uid);
      
      // Save to local storage if found in Firebase
      if (userModel != null) {
        await _localStorageService.saveUser(userModel);
      }
    }
    
    return userModel;
  }
  
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(email, password);
      final userModel = await _firebaseService.getUserProfile(userCredential.user!.uid);
      
      if (userModel == null) {
        throw Exception('User profile not found');
      }
      
      // Save user to local storage
      await _localStorageService.saveUser(userModel);
      
      return userModel;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }
  
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
  
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);
      
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );
      
      await _firebaseService.createUserProfile(userModel);
      await _localStorageService.saveUser(userModel);
      
      return userModel;
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }
  
  Future<void> updateUserProfile(UserModel user) async {
    await _firebaseService.updateUserProfile(user);
    await _localStorageService.saveUser(user);
  }
  
  bool isAdmin(UserModel user) {
    return user.role == 'admin';
  }
  
  bool isOperator(UserModel user) {
    return user.role == 'operator';
  }
}
