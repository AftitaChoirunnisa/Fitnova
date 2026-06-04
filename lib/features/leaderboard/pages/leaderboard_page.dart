import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/user_model.dart';
import '../services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardService _leaderboardService = LeaderboardService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: _leaderboardService.getLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Memuat leaderboard...');
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Gagal memuat leaderboard',
            message:
                'Data ranking belum bisa dimuat. Pastikan koneksi dan index Firestore tersedia.',
            buttonText: 'Coba Lagi',
            onPressed: () => setState(() {}),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(context, 0),
              const SizedBox(height: 16),
              const EmptyStateWidget(
                icon: Icons.emoji_events_outlined,
                title: 'Belum ada ranking',
                message:
                    'Leaderboard akan muncul setelah pengguna mulai mencatat aktivitas olahraga.',
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(context, users.length),
              const SizedBox(height: 16),
              _buildTopUsers(context, users.take(3).toList()),
              const SizedBox(height: 16),
              _buildRankingList(context, users),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, int totalUsers) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 116,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(height: 16),
              Text(
                'Leaderboard FitNova',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalUsers pengguna aktif masuk ranking berdasarkan total durasi olahraga.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsers(BuildContext context, List<AppUser> users) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        child: Column(
          children: [
            Text(
              'Top 3 FitNova',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: users.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final user = entry.value;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: rank == 1 ? 0 : 4,
                      right: rank == users.length ? 0 : 4,
                    ),
                    child: _buildTopUserItem(context, user, rank),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUserItem(BuildContext context, AppUser user, int rank) {
    final color = _getRankColor(rank);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAvatar(user, radius: rank == 1 ? 31 : 27),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRankIcon(rank),
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _displayName(user),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.totalDuration} menit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.totalActivities} aktivitas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(BuildContext context, List<AppUser> users) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.format_list_numbered_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ranking Pengguna',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...users.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              final rank = index + 1;

              return Column(
                children: [
                  _buildRankingTile(context, user, rank),
                  if (index != users.length - 1) const Divider(height: 18),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTile(BuildContext context, AppUser user, int rank) {
    final badgeColor = _getRankColor(rank);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            child: Center(
              child: rank <= 3
                  ? Icon(_getRankIcon(rank), color: badgeColor)
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          _buildAvatar(user, radius: 21),
        ],
      ),
      title: Text(
        _displayName(user),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${user.email} | ${user.totalActivities} aktivitas | ${user.totalCalories} kkal',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${user.totalDuration}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          Text(
            'menit',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AppUser user, {required double radius}) {
    final photoUrl = user.photoUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundImage: photoUrl == null || photoUrl.isEmpty
          ? null
          : NetworkImage(photoUrl),
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              _getInitial(_displayName(user)),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }

  String _displayName(AppUser user) {
    if (user.name.trim().isNotEmpty) {
      return user.name.trim();
    }
    if (user.email.trim().isNotEmpty) {
      return user.email.trim();
    }
    return 'FitNova User';
  }

  String _getInitial(String value) {
    if (value.trim().isEmpty) {
      return 'U';
    }

    return value.trim()[0].toUpperCase();
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.emoji_events_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.warning;
      case 2:
        return Colors.blueGrey;
      case 3:
        return Colors.brown;
      default:
        return AppColors.primary;
    }
  }
}
