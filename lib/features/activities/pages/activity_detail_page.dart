import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/activity_model.dart';
import '../services/activity_service.dart';
import 'add_activity_page.dart';

class ActivityDetailPage extends StatefulWidget {
  final String activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final ActivityService _activityService = ActivityService();

  void _goToEditPage(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddActivityPage(activity: activity)),
    );
  }

  Future<void> _deleteActivity(ActivityModel activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Aktivitas?'),
          content: Text(
            'Aktivitas ${activity.sportType} akan dihapus permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _activityService.deleteActivity(activity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas berhasil dihapus.')),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ActivityModel?>(
      stream: _activityService.getActivityByIdStream(widget.activityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingWidget(message: 'Memuat detail aktivitas...'),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Aktivitas')),
            body: EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat detail',
              message: snapshot.error.toString(),
            ),
          );
        }

        final activity = snapshot.data;

        if (activity == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Aktivitas')),
            body: const EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'Aktivitas tidak ditemukan',
              message:
                  'Data aktivitas ini sudah tidak tersedia atau telah dihapus.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Aktivitas'),
            actions: [
              IconButton(
                onPressed: () => _goToEditPage(activity),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _deleteActivity(activity),
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
                tooltip: 'Hapus',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeroHeader(context, activity),
                  const SizedBox(height: 18),
                  _buildMainInfoCard(context, activity),
                  const SizedBox(height: 18),
                  _buildNoteCard(context, activity),
                  const SizedBox(height: 18),
                  _buildMetadataCard(context, activity),
                  const SizedBox(height: 28),
                  _buildActionButtons(context, activity),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(BuildContext context, ActivityModel activity) {
    final sportColor = _getSportColor(activity.sportType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sportColor, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: sportColor.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Hero(
            tag: 'activity-icon-${activity.id}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getSportIcon(activity.sportType),
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            activity.sportType,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormatter.formatDate(activity.activityDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context, ActivityModel activity) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.timer_outlined,
            title: 'Durasi',
            value: '${activity.duration}',
            unit: 'menit',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.local_fire_department_outlined,
            title: 'Kalori',
            value: '${activity.calories}',
            unit: 'kkal',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, ActivityModel activity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.notes_rounded, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Aktivitas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.note.isEmpty ? '-' : activity.note,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, ActivityModel activity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildMetadataRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal Aktivitas',
              value: DateFormatter.formatDate(activity.activityDate),
            ),
            const Divider(height: 24),
            _buildMetadataRow(
              context,
              icon: Icons.add_circle_outline_rounded,
              label: 'Dibuat',
              value: DateFormatter.formatDateTime(activity.createdAt),
            ),
            const Divider(height: 24),
            _buildMetadataRow(
              context,
              icon: Icons.update_rounded,
              label: 'Terakhir Diubah',
              value: DateFormatter.formatDateTime(activity.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(
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

  Widget _buildActionButtons(BuildContext context, ActivityModel activity) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _goToEditPage(activity),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Aktivitas'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _deleteActivity(activity),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Hapus Aktivitas'),
        ),
      ],
    );
  }

  IconData _getSportIcon(String sportType) {
    switch (sportType) {
      case 'Lari':
        return Icons.directions_run_rounded;
      case 'Jalan Kaki':
        return Icons.directions_walk_rounded;
      case 'Bersepeda':
        return Icons.directions_bike_rounded;
      case 'Renang':
        return Icons.pool_rounded;
      case 'Gym':
        return Icons.fitness_center_rounded;
      case 'Yoga':
        return Icons.self_improvement_rounded;
      case 'Futsal':
        return Icons.sports_soccer_rounded;
      case 'Badminton':
        return Icons.sports_tennis_rounded;
      case 'Basket':
        return Icons.sports_basketball_rounded;
      case 'Workout Rumah':
        return Icons.home_work_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Color _getSportColor(String sportType) {
    switch (sportType) {
      case 'Lari':
        return AppColors.primary;
      case 'Jalan Kaki':
        return AppColors.accent;
      case 'Bersepeda':
        return AppColors.secondary;
      case 'Renang':
        return Colors.cyan;
      case 'Gym':
        return Colors.deepPurple;
      case 'Yoga':
        return Colors.pink;
      case 'Futsal':
        return Colors.orange;
      case 'Badminton':
        return Colors.teal;
      case 'Basket':
        return Colors.brown;
      case 'Workout Rumah':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }
}
