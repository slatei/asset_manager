import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends ChangeNotifier {
  final FirebaseAuth auth;

  User? _user;
  User? get user => _user;

  AuthState({required this.auth}) {
    auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> signOut(VoidCallback onSuccess) async {
    await auth.signOut();
    onSuccess();
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }
}
