import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/user_model.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User belum login.');
    }
    return user.uid;
  }

  Stream<AppUser?> getCurrentUserProfile() async* {
    await ensureCurrentUserDocument();

    yield* _firestore.collection('users').doc(_currentUserId).snapshots().map((
      doc,
    ) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return AppUser.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<AppUser?> getCurrentUserStream() => getCurrentUserProfile();

  Future<void> ensureCurrentUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User belum login.');
    }

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

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? bio,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    final cleanName = name.trim();
    final cleanPhone = phone?.trim();
    final cleanBio = bio?.trim();

    if (cleanName.isEmpty) {
      throw Exception('Nama tidak boleh kosong.');
    }

    try {
      await user.updateDisplayName(cleanName);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': cleanName,
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'phone': cleanPhone?.isEmpty == true ? null : cleanPhone,
        'bio': cleanBio?.isEmpty == true ? null : cleanBio,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: $e');
    }
  }
}
