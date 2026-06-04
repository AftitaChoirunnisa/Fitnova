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
    return StreamBuilder<List<UserModel>>(
      stream: _leaderboardService.getLeaderboardStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(
            message: 'Memuat leaderboard...',
          );
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Gagal memuat leaderboard',
            message: snapshot.error.toString(),
            buttonText: 'Coba Lagi',
            onPressed: () => setState(() {}),
          );
        }

        final users = snapshot.data ?? [];
        final rankedUsers = users.where((user) {
          return user.totalActivities > 0 || user.totalDuration > 0;
        }).toList();

        if (rankedUsers.isEmpty) {
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
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(context, rankedUsers.length),
              const SizedBox(height: 16),
              if (rankedUsers.length >= 3)
                _buildTopThreePodium(context, rankedUsers),
              if (rankedUsers.length >= 3) const SizedBox(height: 16),
              _buildRankingList(context, rankedUsers),
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
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
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

  Widget _buildTopThreePodium(
    BuildContext context,
    List<UserModel> users,
  ) {
    final first = users[0];
    final second = users[1];
    final third = users[2];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        child: Column(
          children: [
            Text(
              'Top 3 FitNova',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildPodiumItem(
                    context,
                    user: second,
                    rank: 2,
                    height: 108,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPodiumItem(
                    context,
                    user: first,
                    rank: 1,
                    height: 138,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPodiumItem(
                    context,
                    user: third,
                    rank: 3,
                    height: 92,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context, {
    required UserModel user,
    required int rank,
    required double height,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 30 : 26,
          backgroundColor: color.withValues(alpha: 0.16),
          child: Text(
            _getInitial(user.name),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: rank == 1 ? 22 : 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name.isEmpty ? 'User' : user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.totalDuration} menit',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.32),
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: rank == 1 ? 28 : 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList(
    BuildContext context,
    List<UserModel> users,
  ) {
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

  Widget _buildRankingTile(
    BuildContext context,
    UserModel user,
    int rank,
  ) {
    final badge = _getRankBadge(rank);
    final badgeColor = _getRankColor(rank);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w900,
              fontSize: rank <= 3 ? 20 : 14,
            ),
          ),
        ),
      ),
      title: Text(
        user.name.isEmpty ? 'FitNova User' : user.name,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${user.totalActivities} aktivitas • ${user.totalCalories} kkal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  String _getInitial(String name) {
    if (name.trim().isEmpty) {
      return 'U';
    }

    return name.trim()[0].toUpperCase();
  }

  String _getRankBadge(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
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