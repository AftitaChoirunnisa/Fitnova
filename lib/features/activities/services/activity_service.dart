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

          activities.sort((a, b) => b.activityDate.compareTo(a.activityDate));

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
    try {
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
      await _recalculateUserStats(userId);
    } catch (e) {
      throw Exception('Gagal menambahkan aktivitas: $e');
    }
  }

  Future<void> updateActivity(ActivityModel activity) async {
    try {
      final userId = _currentUserId;

      if (activity.userId != userId) {
        throw Exception('Kamu tidak memiliki akses untuk mengubah data ini.');
      }

      await _activityCollection
          .doc(activity.id)
          .update(activity.copyWith(updatedAt: DateTime.now()).toMap());

      await _recalculateUserStats(userId);
    } catch (e) {
      throw Exception('Gagal memperbarui aktivitas: $e');
    }
  }

  Future<void> deleteActivity(ActivityModel activity) async {
    try {
      final userId = _currentUserId;

      if (activity.userId != userId) {
        throw Exception('Kamu tidak memiliki akses untuk menghapus data ini.');
      }

      await _activityCollection.doc(activity.id).delete();
      await _recalculateUserStats(userId);
    } catch (e) {
      throw Exception('Gagal menghapus aktivitas: $e');
    }
  }

  Future<void> _recalculateUserStats(String uid) async {
    final snapshot = await _activityCollection
        .where('userId', isEqualTo: uid)
        .get();

    final activities = snapshot.docs.map((doc) {
      return ActivityModel.fromDocument(doc);
    }).toList();

    int totalActivities = activities.length;
    int totalDuration = 0;
    int totalCalories = 0;

    for (final activity in activities) {
      totalDuration += activity.duration;
      totalCalories += activity.calories;
    }

    final currentStreak = _calculateCurrentStreak(activities);
    final highestStreak = _calculateHighestStreak(activities);

    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();
    final userData = userSnapshot.data();
    final data = {
      'uid': uid,
      'email': userData?['email'] ?? _auth.currentUser?.email ?? '',
      'name':
          userData?['name'] ?? _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? '',
      'photoUrl': userData?['photoUrl'] ?? _auth.currentUser?.photoURL,
      'totalActivities': totalActivities,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!userSnapshot.exists) {
      data['phone'] = _auth.currentUser?.phoneNumber;
      data['bio'] = null;
      data['createdAt'] = FieldValue.serverTimestamp();
    } else {
      data['phone'] = userData?['phone'];
      data['bio'] = userData?['bio'];
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  int _calculateCurrentStreak(List<ActivityModel> activities) {
    if (activities.isEmpty) {
      return 0;
    }

    final uniqueDates = activities.map((activity) {
      final date = activity.activityDate;
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    final today = DateTime.now();
    DateTime checkedDate = DateTime(today.year, today.month, today.day);
    int currentStreak = 0;

    while (uniqueDates.contains(checkedDate)) {
      currentStreak++;
      checkedDate = checkedDate.subtract(const Duration(days: 1));
    }

    return currentStreak;
  }

  int _calculateHighestStreak(List<ActivityModel> activities) {
    if (activities.isEmpty) {
      return 0;
    }

    final uniqueDates = activities
        .map((activity) {
          final date = activity.activityDate;
          return DateTime(date.year, date.month, date.day);
        })
        .toSet()
        .toList();

    uniqueDates.sort();

    int highestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < uniqueDates.length; i++) {
      final previousDate = uniqueDates[i - 1];
      final currentDate = uniqueDates[i];

      final difference = currentDate.difference(previousDate).inDays;

      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        currentStreak = 1;
      }

      if (currentStreak > highestStreak) {
        highestStreak = currentStreak;
      }
    }

    return highestStreak;
  }
}
