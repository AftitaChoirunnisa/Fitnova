import 'package:cloud_firestore/cloud_firestore.dart';

typedef AppUser = UserModel;

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String? bio;
  final int totalActivities;
  final int totalDuration;
  final int totalCalories;
  final int currentStreak;
  final int highestStreak;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.bio,
    required this.totalActivities,
    required this.totalDuration,
    required this.totalCalories,
    required this.currentStreak,
    required this.highestStreak,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return UserModel(
      uid: _readString(map['uid'], fallback: id ?? ''),
      name: _readString(map['name']),
      email: _readString(map['email']),
      photoUrl: _readNullableString(map['photoUrl']),
      phone: _readNullableString(map['phone']),
      bio: _readNullableString(map['bio']),
      totalActivities: _readInt(map['totalActivities']),
      totalDuration: _readInt(map['totalDuration']),
      totalCalories: _readInt(map['totalCalories']),
      currentStreak: _readInt(map['currentStreak']),
      highestStreak: _readInt(map['highestStreak']),
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'bio': bio,
      'totalActivities': totalActivities,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    Object? photoUrl = _sentinel,
    Object? phone = _sentinel,
    Object? bio = _sentinel,
    int? totalActivities,
    int? totalDuration,
    int? totalCalories,
    int? currentStreak,
    int? highestStreak,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl == _sentinel ? this.photoUrl : photoUrl as String?,
      phone: phone == _sentinel ? this.phone : phone as String?,
      bio: bio == _sentinel ? this.bio : bio as String?,
      totalActivities: totalActivities ?? this.totalActivities,
      totalDuration: totalDuration ?? this.totalDuration,
      totalCalories: totalCalories ?? this.totalCalories,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      createdAt: createdAt == _sentinel
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt == _sentinel
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static String? _readNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

const Object _sentinel = Object();
