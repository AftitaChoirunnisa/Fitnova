import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/participant_model.dart';
import '../services/challenge_service.dart';
import 'challenge_detail_page.dart';

class MyChallengePage extends StatefulWidget {
  const MyChallengePage({super.key});

  @override
  State<MyChallengePage> createState() => _MyChallengePageState();
}

class _MyChallengePageState extends State<MyChallengePage> {
  final ChallengeService _challengeService = ChallengeService();

  void _goToChallengeDetail(ParticipantModel participant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChallengeDetailPage(challengeId: participant.challengeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Saya')),
      body: StreamBuilder<List<ParticipantModel>>(
        stream: _challengeService.getMyParticipantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Memuat challenge saya...');
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat challenge',
              message: snapshot.error.toString(),
            );
          }

          final participants = snapshot.data ?? [];

          if (participants.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              title: 'Belum join challenge',
              message:
                  'Kamu belum mengikuti challenge apa pun. Pilih challenge untuk mulai meningkatkan motivasi olahraga.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: participants.length,
            // ignore: unnecessary_underscores
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final participant = participants[index];

              return _buildParticipantCard(context, participant);
            },
          );
        },
      ),
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    ParticipantModel participant,
  ) {
    final isCompleted = participant.status == 'completed';

    return Card(
      child: InkWell(
        onTap: () => _goToChallengeDetail(participant),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.emoji_events_rounded,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenge Diikuti',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${participant.progress} menit • ${isCompleted ? 'Selesai' : 'Aktif'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
