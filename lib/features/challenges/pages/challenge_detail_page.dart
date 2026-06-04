import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
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
          backgroundColor: AppColors.error,
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
          title: const Text('Hapus Challenge?'),
          content: Text(
            'Challenge "${challenge.title}" dan data pesertanya akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
          backgroundColor: AppColors.error,
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
          title: const Text('Tambah Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress saat ini: ${participant.progress} menit',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tambah Durasi',
                  hintText: 'Contoh: 40',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final addedProgress = int.tryParse(controller.text.trim());

                if (addedProgress == null || addedProgress <= 0) {
                  return;
                }

                Navigator.pop(context, addedProgress);
              },
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
          backgroundColor: AppColors.error,
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Challenge'),
            actions: [
              IconButton(
                onPressed: _goToStatisticsPage,
                icon: const Icon(Icons.insert_chart_outlined_rounded),
                tooltip: 'Statistik',
              ),
              if (isOwner)
                IconButton(
                  onPressed: () => _goToEditChallenge(challenge),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (isOwner)
                IconButton(
                  onPressed: () => _deleteChallenge(challenge),
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                ),
            ],
          ),
          body: SafeArea(
            child: FutureBuilder<ParticipantModel?>(
              future: _challengeService.getMyParticipant(challenge.id),
              builder: (context, participantSnapshot) {
                final myParticipant = participantSnapshot.data;
                final hasJoined = myParticipant != null;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeader(context, challenge),
                      const SizedBox(height: 18),
                      _buildProgressCard(context, challenge, myParticipant),
                      const SizedBox(height: 18),
                      _buildInfoCard(context, challenge),
                      const SizedBox(height: 18),
                      _buildJoinAction(
                        context,
                        challenge,
                        hasJoined,
                        myParticipant,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _goToStatisticsPage,
                        icon: const Icon(Icons.insert_chart_outlined_rounded),
                        label: const Text('Lihat Statistik Progress'),
                      ),
                      const SizedBox(height: 18),
                      _buildParticipantsSection(challenge),
                      const SizedBox(height: 28),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ChallengeModel challenge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'challenge-icon-${challenge.id}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            challenge.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    ChallengeModel challenge,
    ParticipantModel? participant,
  ) {
    final progress = participant?.progress ?? 0;
    final value = challenge.targetDuration == 0
        ? 0.0
        : (progress / challenge.targetDuration).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Saya',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(99),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  color: participant?.status == 'completed'
                      ? AppColors.success
                      : AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              '$progress / ${challenge.targetDuration} menit',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (participant?.status == 'completed') ...[
              const SizedBox(height: 8),
              const Text(
                'Challenge selesai! Keren, kamu berhasil mencapai target.',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ChallengeModel challenge) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              icon: Icons.category_outlined,
              label: 'Kategori',
              value: challenge.category,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.timer_outlined,
              label: 'Target Durasi',
              value: '${challenge.targetDuration} menit',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.calendar_month_outlined,
              label: 'Target Hari',
              value: '${challenge.targetDays} hari',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.date_range_outlined,
              label: 'Periode',
              value:
                  '${DateFormatter.formatDate(challenge.startDate)} - ${DateFormatter.formatDate(challenge.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinAction(
    BuildContext context,
    ChallengeModel challenge,
    bool hasJoined,
    ParticipantModel? participant,
  ) {
    if (!hasJoined) {
      return ElevatedButton.icon(
        onPressed: _isJoining ? null : _joinChallenge,
        icon: _isJoining
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_task_rounded),
        label: Text(_isJoining ? 'Memproses...' : 'Join Challenge'),
      );
    }

    return ElevatedButton.icon(
      onPressed: participant == null
          ? null
          : () => _showUpdateProgressDialog(challenge, participant),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Progress Saya'),
    );
  }

  Widget _buildParticipantsSection(ChallengeModel challenge) {
    return StreamBuilder<List<ParticipantModel>>(
      stream: _challengeService.getChallengeParticipantsStream(challenge.id),
      builder: (context, snapshot) {
        final participants = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peserta Challenge',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (participants.isEmpty)
                  Text(
                    'Belum ada peserta.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ...participants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final participant = entry.value;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(participant.userName),
                      subtitle: Text(
                        '${participant.progress} menit • ${participant.status == 'completed' ? 'Selesai' : 'Aktif'}',
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
