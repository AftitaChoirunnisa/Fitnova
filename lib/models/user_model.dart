import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final int totalActivities;
  final int totalDuration;
  final int totalCalories;
  final int highestStreak;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.totalActivities,
    required this.totalDuration,
    required this.totalCalories,
    required this.highestStreak,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      totalActivities: map['totalActivities'] ?? 0,
      totalDuration: map['totalDuration'] ?? 0,
      totalCalories: map['totalCalories'] ?? 0,
      highestStreak: map['highestStreak'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'totalActivities': totalActivities,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'highestStreak': highestStreak,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    int? totalActivities,
    int? totalDuration,
    int? totalCalories,
    int? highestStreak,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalActivities: totalActivities ?? this.totalActivities,
      totalDuration: totalDuration ?? this.totalDuration,
      totalCalories: totalCalories ?? this.totalCalories,
      highestStreak: highestStreak ?? this.highestStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}