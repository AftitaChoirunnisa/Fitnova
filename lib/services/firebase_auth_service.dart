import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      await _ensureUserDocument(user);
      final createdSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      return UserModel.fromDocument(createdSnapshot);
    }

    return UserModel.fromMap(snapshot.data()!, snapshot.id);
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Register gagal. User tidak ditemukan.');
      }

      await user.updateDisplayName(name.trim());

      final now = DateTime.now();
      final userModel = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        photoUrl: user.photoURL,
        phone: user.phoneNumber,
        bio: null,
        totalActivities: 0,
        totalDuration: 0,
        totalCalories: 0,
        currentStreak: 0,
        highestStreak: 0,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan saat register: $e');
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: $e');
    }
  }

  Future<void> _ensureUserDocument(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'phone': snapshot.data()?['phone'] ?? user.phoneNumber,
        'bio': snapshot.data()?['bio'],
        'totalActivities': snapshot.data()?['totalActivities'] ?? 0,
        'totalDuration': snapshot.data()?['totalDuration'] ?? 0,
        'totalCalories': snapshot.data()?['totalCalories'] ?? 0,
        'currentStreak': snapshot.data()?['currentStreak'] ?? 0,
        'highestStreak': snapshot.data()?['highestStreak'] ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final now = DateTime.now();
    final appUser = AppUser(
      uid: user.uid,
      name: user.displayName ?? user.email ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      phone: user.phoneNumber,
      bio: null,
      totalActivities: 0,
      totalDuration: 0,
      totalCalories: 0,
      currentStreak: 0,
      highestStreak: 0,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(appUser.toMap());
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan. Gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return 'Autentikasi gagal. Silakan coba lagi.';
    }
  }
}
