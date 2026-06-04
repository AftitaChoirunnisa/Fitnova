import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppUser>> getLeaderboard() {
    return _firestore
        .collection('users')
        .orderBy('totalDuration', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => AppUser.fromDocument(doc))
              .where(
                (user) => user.totalActivities > 0 || user.totalDuration > 0,
              )
              .toList();

          users.sort((a, b) {
            final durationCompare = b.totalDuration.compareTo(a.totalDuration);
            if (durationCompare != 0) {
              return durationCompare;
            }

            final activityCompare = b.totalActivities.compareTo(
              a.totalActivities,
            );
            if (activityCompare != 0) {
              return activityCompare;
            }

            return b.totalCalories.compareTo(a.totalCalories);
          });

          return users;
        });
  }

  Stream<List<AppUser>> getLeaderboardStream() => getLeaderboard();
}
