import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getLeaderboardStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final users = snapshot.docs.map((doc) {
        return UserModel.fromDocument(doc);
      }).toList();

      users.sort((a, b) {
        final durationCompare = b.totalDuration.compareTo(a.totalDuration);

        if (durationCompare != 0) {
          return durationCompare;
        }

        return b.totalActivities.compareTo(a.totalActivities);
      });

      return users;
    });
  }
}