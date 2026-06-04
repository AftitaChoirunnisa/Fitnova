import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    return user.uid;
  }

  CollectionReference get _activityCollection {
    return _firestore.collection('activities');
  }

  Stream<List<ActivityModel>> getUserActivitiesStream() {
    final userId = _currentUserId;

    return _activityCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final activities = snapshot.docs.map((doc) {
        return ActivityModel.fromDocument(doc);
      }).toList();

      activities.sort(
        (a, b) => b.activityDate.compareTo(a.activityDate),
      );

      return activities;
    });
  }

  Stream<ActivityModel?> getActivityByIdStream(String activityId) {
    final userId = _currentUserId;

    return _activityCollection.doc(activityId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final activity = ActivityModel.fromDocument(doc);

      if (activity.userId != userId) {
        throw Exception('Kamu tidak memiliki akses ke aktivitas ini.');
      }

      return activity;
    });
  }

  Future<void> addActivity({
    required String sportType,
    required int duration,
    required int calories,
    required DateTime activityDate,
    required String note,
  }) async {
    final userId = _currentUserId;
    final now = DateTime.now();

    final docRef = _activityCollection.doc();

    final activity = ActivityModel(
      id: docRef.id,
      userId: userId,
      sportType: sportType,
      duration: duration,
      calories: calories,
      activityDate: activityDate,
      note: note,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(activity.toMap());
    await _updateUserTotalActivities();
  }

  Future<void> updateActivity(ActivityModel activity) async {
    final userId = _currentUserId;

    if (activity.userId != userId) {
      throw Exception('Kamu tidak memiliki akses untuk mengubah data ini.');
    }

    await _activityCollection.doc(activity.id).update(
          activity.copyWith(
            updatedAt: DateTime.now(),
          ).toMap(),
        );
  }

  Future<void> deleteActivity(ActivityModel activity) async {
    final userId = _currentUserId;

    if (activity.userId != userId) {
      throw Exception('Kamu tidak memiliki akses untuk menghapus data ini.');
    }

    await _activityCollection.doc(activity.id).delete();
    await _updateUserTotalActivities();
  }

  Future<void> _updateUserTotalActivities() async {
    final userId = _currentUserId;

    final snapshot = await _activityCollection
        .where('userId', isEqualTo: userId)
        .get();

    await _firestore.collection('users').doc(userId).update({
      'totalActivities': snapshot.docs.length,
    });
  }
}