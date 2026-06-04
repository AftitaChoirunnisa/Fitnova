import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantModel {
  final String id;
  final String challengeId;
  final String userId;
  final String userName;
  final int progress;
  final DateTime joinedAt;
  final String status;

  ParticipantModel({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.userName,
    required this.progress,
    required this.joinedAt,
    required this.status,
  });

  factory ParticipantModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ParticipantModel(
      id: doc.id,
      challengeId: data['challengeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      progress: data['progress'] ?? 0,
      joinedAt: data['joinedAt'] is Timestamp
          ? (data['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'userName': userName,
      'progress': progress,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'status': status,
    };
  }

  ParticipantModel copyWith({
    String? id,
    String? challengeId,
    String? userId,
    String? userName,
    int? progress,
    DateTime? joinedAt,
    String? status,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      progress: progress ?? this.progress,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
    );
  }
}
