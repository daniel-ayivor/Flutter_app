import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _role;
  bool _firebaseAvailable = false;

  AuthProvider() {
    _initializeFirebase();
  }

  void _initializeFirebase() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _firebaseAvailable = true;
      
      _auth!.authStateChanges().listen((user) async {
        _user = user;
        if (_user != null) {
          await _fetchUserRole();
        } else {
          _role = null;
        }
        notifyListeners();
      });
    } catch (e) {
      print('Firebase not available: $e');
      _firebaseAvailable = false;
      // Set default values for demo
      _user = null;
      _role = 'user';
      notifyListeners();
    }
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String? get role => _role;
  bool get firebaseAvailable => _firebaseAvailable;

  Future<void> signIn(String email, String password) async {
    if (!_firebaseAvailable) {
      _error = 'Firebase not available. Please check configuration.';
      return;
    }
    
    _setLoading(true);
    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      await _fetchUserRole();
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, {String name = '', String role = 'user'}) async {
    if (!_firebaseAvailable) {
      _error = 'Firebase not available. Please check configuration.';
      return;
    }
    
    _setLoading(true);
    try {
      UserCredential cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      // Set user data in Firestore
      await _firestore!.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
      });
      _role = role;
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserRole() async {
    if (_user == null || !_firebaseAvailable) return;
    try {
      final doc = await _firestore!.collection('users').doc(_user!.uid).get();
      _role = doc.data()?['role'] ?? 'user';
    } catch (e) {
      _role = 'user';
    }
  }

  Future<void> signOut() async {
    if (_firebaseAvailable && _auth != null) {
      await _auth!.signOut();
    }
    _user = null;
    _role = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_user == null) {
      _error = 'No user logged in';
      return;
    }

    _setLoading(true);
    try {
      // Update Firebase Auth profile
      if (_firebaseAvailable && displayName != null) {
        await _user!.updateDisplayName(displayName);
      }

      // Update Firestore user document
      if (_firebaseAvailable) {
        Map<String, dynamic> updateData = {};
        if (displayName != null) updateData['displayName'] = displayName;
        if (phone != null) updateData['phone'] = phone;
        if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
        
        if (updateData.isNotEmpty) {
          await _firestore!.collection('users').doc(_user!.uid).update(updateData);
        }
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) {
      _error = 'No user logged in';
      return;
    }

    if (!_firebaseAvailable) {
      _error = 'Firebase not available. Please check configuration.';
      return;
    }

    _setLoading(true);
    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      
      await _user!.reauthenticateWithCredential(credential);
      
      // Update password
      await _user!.updatePassword(newPassword);
      
      _error = null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _error = 'Current password is incorrect';
          break;
        case 'weak-password':
          _error = 'New password is too weak';
          break;
        case 'requires-recent-login':
          _error = 'Please log out and log back in before changing password';
          break;
        default:
          _error = e.message ?? 'Failed to change password';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
