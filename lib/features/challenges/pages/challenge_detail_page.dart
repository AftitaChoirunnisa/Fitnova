import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/soft_gradient_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/challenge_model.dart';
import '../../../models/participant_model.dart';
import '../../statistics/pages/statistics_page.dart';
import '../services/challenge_service.dart';
import 'add_challenge_page.dart';

class ChallengeDetailPage extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailPage({super.key, required this.challengeId});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  final ChallengeService _challengeService = ChallengeService();
  bool _isJoining = false;

  Future<void> _joinChallenge() async {
    setState(() {
      _isJoining = true;
    });

    try {
      await _challengeService.joinChallenge(widget.challengeId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berhasil join challenge.')));

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  void _goToEditChallenge(ChallengeModel challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddChallengePage(challenge: challenge)),
    );
  }

  void _goToStatisticsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsPage()),
    );
  }

  Future<void> _deleteChallenge(ChallengeModel challenge) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.softCard,
          title: Text('Hapus Challenge?', style: AppTextStyles.headingSmall),
          content: Text(
            'Challenge "${challenge.title}" dan data pesertanya akan dihapus.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _challengeService.deleteChallenge(challenge);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge berhasil dihapus.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _showUpdateProgressDialog(
    ChallengeModel challenge,
    ParticipantModel participant,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.softCard,
          title: Text('Tambah Progress', style: AppTextStyles.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress saat ini: ${participant.progress} menit',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller,
                keyboardType: TextInputType.number,
                label: 'Tambah Durasi (menit)',
                hint: 'Contoh: 40',
                prefixIcon: Icons.timer_outlined,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final addedProgress = int.tryParse(controller.text.trim());

                if (addedProgress == null || addedProgress <= 0) {
                  return;
                }

                Navigator.pop(context, addedProgress);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    try {
      await _challengeService.addMyChallengeProgress(
        participantId: participant.id,
        addedProgress: result,
        targetDuration: challenge.targetDuration,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress challenge berhasil ditambahkan.'),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChallengeModel?>(
      stream: _challengeService.getChallengeByIdStream(widget.challengeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: LoadingWidget(message: 'Memuat detail challenge...'),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Challenge')),
            body: EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat challenge',
              message: snapshot.error.toString(),
            ),
          );
        }

        final challenge = snapshot.data;

        if (challenge == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Challenge')),
            body: const EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'Challenge tidak ditemukan',
              message: 'Challenge ini sudah dihapus atau tidak tersedia.',
            ),
          );
        }

        final isOwner = challenge.createdBy == _challengeService.currentUserId;

        return AppScaffold(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          appBarTitle: 'Challenge Details',
          appBarActions: [
            IconButton(
              onPressed: _goToStatisticsPage,
              icon: const Icon(
                Icons.insert_chart_outlined_rounded,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Statistik',
            ),
            if (isOwner)
              IconButton(
                onPressed: () => _goToEditChallenge(challenge),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textPrimary,
                ),
              ),
            if (isOwner)
              IconButton(
                onPressed: () => _deleteChallenge(challenge),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
          ],
          body: FutureBuilder<ParticipantModel?>(
            future: _challengeService.getMyParticipant(challenge.id),
            builder: (context, participantSnapshot) {
              final myParticipant = participantSnapshot.data;
              final hasJoined = myParticipant != null;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(challenge),
                    const SizedBox(height: 20),
                    if (hasJoined) ...[
                      _buildProgressCard(challenge, myParticipant),
                      const SizedBox(height: 20),
                    ],
                    _buildInfoCard(challenge),
                    const SizedBox(height: 24),
                    _buildJoinAction(challenge, hasJoined, myParticipant),
                    const SizedBox(height: 24),
                    _buildParticipantsSection(challenge),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ChallengeModel challenge) {
    return SoftGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.category,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            challenge.title,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    ChallengeModel challenge,
    ParticipantModel? participant,
  ) {
    final progress = participant?.progress ?? 0;
    final value = challenge.targetDuration == 0
        ? 0.0
        : (progress / challenge.targetDuration).clamp(0.0, 1.0);

    final isCompleted = participant?.status == 'completed';

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Progress',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryGreen,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressBar(
            value: value,
            progressColor: isCompleted
                ? AppColors.primaryGreen
                : AppColors.softMint,
            backgroundColor: AppColors.darkGreen,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progress / ${challenge.targetDuration} mins completed',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ChallengeModel challenge) {
    return SoftCard(
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: challenge.category,
          ),
          const Divider(height: 24, color: AppColors.borderSoft),
          _buildInfoRow(
            icon: Icons.timer_outlined,
            label: 'Target Duration',
            value: '${challenge.targetDuration} mins',
          ),
          const Divider(height: 24, color: AppColors.borderSoft),
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Target Days',
            value: '${challenge.targetDays} days',
          ),
          const Divider(height: 24, color: AppColors.borderSoft),
          _buildInfoRow(
            icon: Icons.date_range_outlined,
            label: 'Period',
            value:
                '${DateFormatter.formatDate(challenge.startDate)} - ${DateFormatter.formatDate(challenge.endDate)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinAction(
    ChallengeModel challenge,
    bool hasJoined,
    ParticipantModel? participant,
  ) {
    if (!hasJoined) {
      return PrimaryButton(
        text: 'Join Challenge',
        isLoading: _isJoining,
        onPressed: _joinChallenge,
      );
    }

    return Column(
      children: [
        PrimaryButton(
          text: 'Update My Progress',
          onPressed: participant == null
              ? null
              : () => _showUpdateProgressDialog(challenge, participant),
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          text: 'View Progress Statistics',
          onPressed: _goToStatisticsPage,
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(ChallengeModel challenge) {
    return StreamBuilder<List<ParticipantModel>>(
      stream: _challengeService.getChallengeParticipantsStream(challenge.id),
      builder: (context, snapshot) {
        final participants = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SoftCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          );
        }

        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Challenge Participants',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (participants.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No participants yet. Be the first to join!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: participants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    final isCompleted = participant.status == 'completed';

                    return Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderSoft),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant.userName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${participant.progress} mins completed',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.primaryGreen.withOpacity(0.1)
                                : AppColors.softCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.primaryGreen
                                  : AppColors.borderSoft,
                            ),
                          ),
                          child: Text(
                            isCompleted ? 'Completed' : 'Active',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isCompleted
                                  ? AppColors.primaryGreen
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
