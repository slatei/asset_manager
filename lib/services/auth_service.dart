import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<void> signOut({required VoidCallback onSuccess}) async {
    await _firebaseAuth.signOut();
    onSuccess();
  }
}
