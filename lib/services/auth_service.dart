import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(), password: password,
    );
    await credential.user!.updateDisplayName(name.trim());
    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name.trim(), 'email': email.trim(), 'phone': '',
      'address': '', 'city': '', 'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> logout() => _auth.signOut();
  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email.trim());
}
