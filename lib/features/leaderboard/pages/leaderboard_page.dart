import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/soft_gradient_card.dart';
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
    return AppScaffold(
      appBarTitle: 'Leaderboard',
      body: StreamBuilder<List<AppUser>>(
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
                  'Data ranking belum bisa dimuat. Pastikan koneksi internet tersedia.',
              buttonText: 'Coba Lagi',
              onPressed: () => setState(() {}),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Column(
              children: [
                _buildHeader(0),
                const SizedBox(height: 16),
                const Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.emoji_events_outlined,
                    title: 'Belum ada ranking',
                    message:
                        'Leaderboard akan muncul setelah pengguna mulai mencatat aktivitas olahraga.',
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.softCard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(users.length),
                  const SizedBox(height: 24),
                  if (users.isNotEmpty) ...[
                    _buildPodium(users.take(3).toList()),
                    const SizedBox(height: 28),
                  ],
                  _buildRankingList(users),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int totalUsers) {
    return SoftGradientCard(
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 130,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.leaderboard_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Leaderboard',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalUsers active users ranked by their total workout duration this week.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<AppUser> topUsers) {
    // Reorder for podium display: [2nd, 1st, 3rd]
    List<Widget> podiumWidgets = [];

    if (topUsers.length > 1) {
      podiumWidgets.add(
        Expanded(
          child: _buildPodiumSlot(topUsers[1], 2, 55, AppColors.borderSoft),
        ),
      );
    } else {
      podiumWidgets.add(const Expanded(child: SizedBox()));
    }

    if (topUsers.isNotEmpty) {
      podiumWidgets.add(
        Expanded(
          child: _buildPodiumSlot(topUsers[0], 1, 80, AppColors.warning),
        ),
      );
    }

    if (topUsers.length > 2) {
      podiumWidgets.add(
        Expanded(
          child: _buildPodiumSlot(topUsers[2], 3, 40, Colors.brown.shade400),
        ),
      );
    } else {
      podiumWidgets.add(const Expanded(child: SizedBox()));
    }

    return SoftCard(
      child: Column(
        children: [
          Text(
            'Top Performers',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: podiumWidgets,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSlot(
    AppUser user,
    int rank,
    double blockHeight,
    Color accentColor,
  ) {
    final photoUrl = user.photoUrl;
    final isFirst = rank == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: isFirst ? 2.5 : 1.5,
                ),
                boxShadow: isFirst
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: isFirst ? 32 : 26,
                backgroundColor: AppColors.darkGreen,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Text(
                        _getInitial(user.name),
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isFirst ? 20 : 16,
                        ),
                      )
                    : null,
              ),
            ),
            if (isFirst)
              const Positioned(
                top: -18,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          user.name.isNotEmpty ? user.name : 'FitNova User',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isFirst ? 14 : 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${user.totalDuration} mins',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: blockHeight,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.25),
                accentColor.withOpacity(0.08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              top: BorderSide(color: accentColor, width: 2),
              left: BorderSide(color: AppColors.borderSoft),
              right: BorderSide(color: AppColors.borderSoft),
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: AppTextStyles.headingMedium.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList(List<AppUser> users) {
    // Filter users ranked 4th and below
    final rankList = users.asMap().entries.toList();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_list_numbered_rounded,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rankings',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = rankList[index];
              final userIndex = entry.key;
              final user = entry.value;
              final rank = userIndex + 1;

              final photoUrl = user.photoUrl;

              return Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: rank <= 3
                              ? (rank == 1
                                    ? AppColors.warning
                                    : (rank == 2
                                          ? AppColors.textSecondary
                                          : Colors.brown.shade300))
                              : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Text(
                            _getInitial(user.name),
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : 'FitNova User',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.totalActivities} activities • ${user.totalCalories} kcal',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.totalDuration}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'mins',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getInitial(String name) {
    if (name.trim().isEmpty) return 'U';
    return name.trim()[0].toUpperCase();
  }
}
