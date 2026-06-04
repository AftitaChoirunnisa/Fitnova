import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_auth_service.dart';
import '../../statistics/pages/statistics_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getCurrentUserData();
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout berhasil.'),
        ),
      );
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

  Future<void> _refreshProfile() async {
    setState(() {
      _userFuture = _authService.getCurrentUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(
            message: 'Memuat profil...',
          );
        }

        final user = snapshot.data;

        return RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 16),
              _buildProfileStats(context, user),
              const SizedBox(height: 16),
              _buildProfileMenu(context),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user) {
    final name = user?.name.isNotEmpty == true ? user!.name : 'FitNova User';
    final email = user?.email ?? '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                _getInitial(name),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context, UserModel? user) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Aktivitas',
                value: '${user?.totalActivities ?? 0}',
                icon: Icons.fitness_center_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Streak',
                value: '${user?.highestStreak ?? 0}',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Durasi',
                value: '${user?.totalDuration ?? 0}',
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Kalori',
                value: '${user?.totalCalories ?? 0}',
                icon: Icons.whatshot_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.insert_chart_outlined_rounded,
            title: 'Statistik Progress',
            subtitle: 'Lihat grafik, target mingguan, dan insight olahraga',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatisticsPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            subtitle: 'Fitur ini akan dibuat setelah fitur utama selesai',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profil akan dibuat pada tahap berikutnya.'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang FitNova',
            subtitle: 'Aplikasi social fitness untuk UAS Mobile',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'FitNova',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.primary,
                ),
                children: const [
                  Text(
                    'FitNova membantu pengguna mencatat aktivitas olahraga, mengikuti challenge, melihat leaderboard, dan memantau progress kebugaran.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  String _getInitial(String name) {
    if (name.trim().isEmpty) {
      return 'U';
    }

    return name.trim()[0].toUpperCase();
  }
}