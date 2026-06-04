import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/soft_gradient_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/user_model.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();

  void _goToEditProfile(AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.softCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text('Logout', style: AppTextStyles.headingSmall),
          content: Text(
            'Apakah kamu yakin ingin keluar dari FitNova?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _profileService.logout();
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

  void _showAboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'FitNova',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGreen),
        ),
        child: const Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primaryGreen,
        ),
      ),
      children: const [
        Text(
          'FitNova membantu mencatat aktivitas olahraga, statistik progress, streak, challenge, leaderboard, dan profil pengguna.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Profile',
      body: StreamBuilder<AppUser?>(
        stream: _profileService.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Memuat profil...');
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat profil',
              message: snapshot.error.toString(),
              buttonText: 'Coba Lagi',
              onPressed: () => setState(() {}),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return EmptyStateWidget(
              icon: Icons.person_off_outlined,
              title: 'Profil tidak ditemukan',
              message: 'Data pengguna belum tersedia di database.',
              buttonText: 'Muat Ulang',
              onPressed: () => setState(() {}),
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
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildStatisticGrid(user),
                  const SizedBox(height: 16),
                  _buildHighestStreakCard(user),
                  const SizedBox(height: 20),
                  _buildMenuSection(user),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    final displayName = _displayName(user);

    return SoftGradientCard(
      child: Column(
        children: [
          _buildAvatar(user, radius: 44),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (user.bio?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _goToEditProfile(user),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticGrid(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Activity Summary',
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _buildStatCell(
              icon: Icons.fitness_center_rounded,
              title: 'Activities',
              value: '${user.totalActivities}',
              subtitle: 'workouts',
              color: AppColors.primaryGreen,
            ),
            _buildStatCell(
              icon: Icons.timer_outlined,
              title: 'Duration',
              value: '${user.totalDuration}',
              subtitle: 'mins',
              color: AppColors.softMint,
            ),
            _buildStatCell(
              icon: Icons.local_fire_department_rounded,
              title: 'Calories',
              value: '${user.totalCalories}',
              subtitle: 'kcal',
              color: AppColors.warning,
            ),
            _buildStatCell(
              icon: Icons.whatshot_rounded,
              title: 'Active Streak',
              value: '${user.currentStreak}',
              subtitle: 'days',
              color: AppColors.danger,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCell({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighestStreakCard(AppUser user) {
    return SoftCard(
      color: AppColors.cardSecondary,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Best',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Highest Streak: ${user.highestStreak} days',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AppUser user) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.edit_outlined,
            iconColor: AppColors.primaryGreen,
            title: 'Edit Profile',
            subtitle: 'Change name, phone, and bio',
            onTap: () => _goToEditProfile(user),
          ),
          const Divider(height: 1, color: AppColors.borderSoft),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.softMint,
            title: 'About FitNova',
            subtitle: 'App information and updates',
            onTap: _showAboutApp,
          ),
          const Divider(height: 1, color: AppColors.borderSoft),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            title: 'Sign Out',
            subtitle: 'Sign out of your FitNova account',
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildAvatar(AppUser user, {required double radius}) {
    final photoUrl = user.photoUrl;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: photoUrl == null || photoUrl.isEmpty
            ? Text(
                _getInitial(_displayName(user)),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.78,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
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
}
