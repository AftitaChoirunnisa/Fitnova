import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String userId;
  final String sportType;
  final int duration;
  final int calories;
  final DateTime activityDate;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.sportType,
    required this.duration,
    required this.calories,
    required this.activityDate,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sportType: data['sportType'] ?? '',
      duration: data['duration'] ?? 0,
      calories: data['calories'] ?? 0,
      activityDate: data['activityDate'] is Timestamp
          ? (data['activityDate'] as Timestamp).toDate()
          : DateTime.now(),
      note: data['note'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sportType': sportType,
      'duration': duration,
      'calories': calories,
      'activityDate': Timestamp.fromDate(activityDate),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    String? sportType,
    int? duration,
    int? calories,
    DateTime? activityDate,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sportType: sportType ?? this.sportType,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      activityDate: activityDate ?? this.activityDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}