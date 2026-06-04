import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Logout'),
          content: const Text('Apakah kamu yakin ingin keluar dari FitNova?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
          backgroundColor: AppColors.error,
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
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.fitness_center_rounded, color: Colors.white),
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
    return StreamBuilder<AppUser?>(
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 16),
              _buildStatisticSection(context, user),
              const SizedBox(height: 16),
              _buildAccountSection(context, user),
              const SizedBox(height: 16),
              _buildMenuSection(context, user),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    final displayName = _displayName(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(user, radius: 44, foregroundColor: Colors.white),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          if (user.bio?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _goToEditProfile(user),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticSection(BuildContext context, AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              icon: Icons.insert_chart_outlined_rounded,
              title: 'Ringkasan Progress',
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.fitness_center_rounded,
                  title: 'Aktivitas',
                  value: '${user.totalActivities}',
                  subtitle: 'total olahraga',
                  color: AppColors.primary,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.timer_outlined,
                  title: 'Durasi',
                  value: '${user.totalDuration}',
                  subtitle: 'menit',
                  color: AppColors.secondary,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  title: 'Kalori',
                  value: '${user.totalCalories}',
                  subtitle: 'kkal',
                  color: AppColors.warning,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.whatshot_rounded,
                  title: 'Streak',
                  value: '${user.currentStreak}',
                  subtitle: 'hari saat ini',
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              icon: Icons.workspace_premium_outlined,
              title: 'Highest Streak',
              value: '${user.highestStreak} hari terbaik',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const Spacer(),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AppUser user) {
    final dateText = user.createdAt == null
        ? 'Belum tersedia'
        : DateFormat('dd MMMM yyyy').format(user.createdAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              icon: Icons.account_circle_outlined,
              title: 'Informasi Akun',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Nama',
              value: user.name.isEmpty ? 'Belum diisi' : user.name,
            ),
            const Divider(height: 22),
            _buildInfoTile(
              context,
              icon: Icons.email_outlined,
              title: 'Email',
              value: user.email,
            ),
            const Divider(height: 22),
            _buildInfoTile(
              context,
              icon: Icons.phone_outlined,
              title: 'Telepon',
              value: user.phone?.isNotEmpty == true
                  ? user.phone!
                  : 'Belum diisi',
            ),
            const Divider(height: 22),
            _buildInfoTile(
              context,
              icon: Icons.calendar_month_outlined,
              title: 'Bergabung',
              value: dateText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Edit Profil'),
              subtitle: const Text('Ubah nama, nomor telepon, dan bio'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _goToEditProfile(user),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.secondary,
              ),
              title: const Text('Tentang Aplikasi'),
              subtitle: const Text('Informasi singkat FitNova'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _showAboutApp,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Logout'),
              subtitle: const Text('Keluar dari akun FitNova'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildAvatar(
    AppUser user, {
    required double radius,
    required Color foregroundColor,
  }) {
    final photoUrl = user.photoUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: foregroundColor.withValues(alpha: 0.18),
      backgroundImage: photoUrl == null || photoUrl.isEmpty
          ? null
          : NetworkImage(photoUrl),
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              _getInitial(_displayName(user)),
              style: TextStyle(
                color: foregroundColor,
                fontSize: radius * 0.78,
                fontWeight: FontWeight.w900,
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
}
