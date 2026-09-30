import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../constants.dart';
import 'package:flores_mobile/models/user.dart' as app_user;

enum LoginType { dummyjson, firebase }

class UserService {
  Map<String, dynamic> data = {};

  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  // ─────────────────────────────────────────────────────────
  //  DummyJSON login (existing)
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body) as Map<String, dynamic>;
      await saveUserData(data);
      await _saveLoginType(LoginType.dummyjson);
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Firebase Auth — sign in with email & password
  // ─────────────────────────────────────────────────────────
  Future<fb_auth.UserCredential> signIn(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Persist to SharedPreferences so the rest of the app works.
      final fbUser = credential.user!;
      await saveUserData({
        'id': fbUser.uid.hashCode,
        'username': fbUser.displayName ?? email.split('@').first,
        'email': fbUser.email ?? email,
        'firstName': fbUser.displayName ?? '',
        'lastName': '',
        'gender': '',
        'image': fbUser.photoURL ?? '',
        'accessToken': await fbUser.getIdToken() ?? '',
        'refreshToken': fbUser.refreshToken ?? '',
      });
      await _saveLoginType(LoginType.firebase);
      return credential;
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Firebase Auth — create account
  // ─────────────────────────────────────────────────────────
  Future<fb_auth.UserCredential> createAccount(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveLoginType(LoginType.firebase);
      return credential;
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Firebase Auth — update display name
  // ─────────────────────────────────────────────────────────
  Future<void> updateUsername(String newUsername) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in.');
    await user.updateDisplayName(newUsername);
    await user.reload();

    // Keep SharedPreferences in sync.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    await prefs.setString('firstName', newUsername);
  }

  // ─────────────────────────────────────────────────────────
  //  Firebase Auth — reset password from current password
  // ─────────────────────────────────────────────────────────
  Future<void> resetPasswordFromCurrentPassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user signed in.');
    }

    // Re-authenticate first.
    final credential = fb_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Then update password.
    await user.updatePassword(newPassword);
  }

  // ─────────────────────────────────────────────────────────
  //  Firebase Auth — delete account
  // ─────────────────────────────────────────────────────────
  Future<void> deleteAccount(String currentPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user signed in.');
    }

    // Re-authenticate before destructive action.
    final credential = fb_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();

    // Clean up local session.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─────────────────────────────────────────────────────────
  //  Sign out (works for both dummyjson and firebase)
  // ─────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      // Sign out of Firebase if there is a current Firebase user.
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
      }
      // Clear SharedPreferences session data.
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  SharedPreferences helpers (existing, preserved)
  // ─────────────────────────────────────────────────────────

  /// Save user data from API response based on the app User model.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = app_user.User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);

    // Support generic token key if present in API response.
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token']?.toString() ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  /// Retrieve user data from SharedPreferences.
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
    };
  }

  /// Retrieve the application User model from SharedPreferences.
  Future<app_user.User> getUser() async {
    final userData = await getUserData();
    return app_user.User.fromJson(userData);
  }

  /// Check if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    // Check Firebase auth first.
    if (_firebaseAuth.currentUser != null) return true;

    // Fallback to SharedPreferences token check (dummyjson flow).
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  /// Logout and clear stored user data.
  /// Kept for backward compatibility — delegates to signOut().
  Future<void> logout() async {
    await signOut();
  }

  // ─────────────────────────────────────────────────────────
  //  Login type tracking
  // ─────────────────────────────────────────────────────────
  Future<void> _saveLoginType(LoginType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginType', type.name);
  }

  Future<LoginType> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    final typeStr = prefs.getString('loginType') ?? 'dummyjson';
    return LoginType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => LoginType.dummyjson,
    );
  }

  /// Get the current Firebase user (null if none).
  fb_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;
}
