import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/challenge_model.dart';
import '../../../models/participant_model.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    return user.uid;
  }

  CollectionReference get _challengeCollection {
    return _firestore.collection('challenges');
  }

  CollectionReference get _participantCollection {
    return _firestore.collection('challengeParticipants');
  }

  Stream<List<ChallengeModel>> getChallengesStream() {
    return _challengeCollection.snapshots().map((snapshot) {
      final challenges = snapshot.docs.map((doc) {
        return ChallengeModel.fromDocument(doc);
      }).toList();

      challenges.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return challenges;
    });
  }

  Stream<ChallengeModel?> getChallengeByIdStream(String challengeId) {
    return _challengeCollection.doc(challengeId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return ChallengeModel.fromDocument(doc);
    });
  }

  Stream<List<ParticipantModel>> getChallengeParticipantsStream(
    String challengeId,
  ) {
    return _participantCollection
        .where('challengeId', isEqualTo: challengeId)
        .snapshots()
        .map((snapshot) {
      final participants = snapshot.docs.map((doc) {
        return ParticipantModel.fromDocument(doc);
      }).toList();

      participants.sort((a, b) => b.progress.compareTo(a.progress));

      return participants;
    });
  }

  Stream<List<ParticipantModel>> getMyParticipantsStream() {
    final userId = _currentUserId;

    return _participantCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final participants = snapshot.docs.map((doc) {
        return ParticipantModel.fromDocument(doc);
      }).toList();

      participants.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));

      return participants;
    });
  }

  Future<void> addChallenge({
    required String title,
    required String description,
    required String category,
    required int targetDuration,
    required int targetDays,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = _currentUserId;
    final now = DateTime.now();

    final docRef = _challengeCollection.doc();

    final challenge = ChallengeModel(
      id: docRef.id,
      title: title,
      description: description,
      category: category,
      targetDuration: targetDuration,
      targetDays: targetDays,
      startDate: startDate,
      endDate: endDate,
      createdBy: userId,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(challenge.toMap());
  }

  Future<void> updateChallenge(ChallengeModel challenge) async {
    final userId = _currentUserId;

    if (challenge.createdBy != userId) {
      throw Exception('Kamu hanya bisa mengedit challenge yang kamu buat.');
    }

    await _challengeCollection.doc(challenge.id).update(
          challenge.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  Future<void> deleteChallenge(ChallengeModel challenge) async {
    final userId = _currentUserId;

    if (challenge.createdBy != userId) {
      throw Exception('Kamu hanya bisa menghapus challenge yang kamu buat.');
    }

    final participantsSnapshot = await _participantCollection
        .where('challengeId', isEqualTo: challenge.id)
        .get();

    final batch = _firestore.batch();

    for (final doc in participantsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_challengeCollection.doc(challenge.id));

    await batch.commit();
  }

  Future<bool> hasJoinedChallenge(String challengeId) async {
    final userId = _currentUserId;

    final snapshot = await _participantCollection
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> joinChallenge(String challengeId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    final alreadyJoined = await hasJoinedChallenge(challengeId);

    if (alreadyJoined) {
      throw Exception('Kamu sudah join challenge ini.');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final userName = userData?['name'] ?? user.displayName ?? 'FitNova User';

    final docRef = _participantCollection.doc();

    final participant = ParticipantModel(
      id: docRef.id,
      challengeId: challengeId,
      userId: user.uid,
      userName: userName,
      progress: 0,
      joinedAt: DateTime.now(),
      status: 'active',
    );

    await docRef.set(participant.toMap());
  }

  Future<void> addMyChallengeProgress({
    required String participantId,
    required int addedProgress,
    required int targetDuration,
  }) async {
    final userId = _currentUserId;

    final doc = await _participantCollection.doc(participantId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Data peserta challenge tidak ditemukan.');
    }

    final participant = ParticipantModel.fromDocument(doc);

    if (participant.userId != userId) {
      throw Exception('Kamu hanya bisa mengubah progress milikmu sendiri.');
    }

    if (addedProgress <= 0) {
      throw Exception('Progress tambahan harus lebih dari 0.');
    }

    final newProgress = participant.progress + addedProgress;
    final status = newProgress >= targetDuration ? 'completed' : 'active';

    await _participantCollection.doc(participantId).update({
      'progress': newProgress,
      'status': status,
    });
  }
  
  Future<ParticipantModel?> getMyParticipant(String challengeId) async {
    final userId = _currentUserId;

    final snapshot = await _participantCollection
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return ParticipantModel.fromDocument(snapshot.docs.first);
  }

  String get currentUserId => _currentUserId;
}