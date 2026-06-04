import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/soft_gradient_card.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/feature_icon_button.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/user_model.dart';
import '../../../models/activity_model.dart';
import '../../../services/firebase_auth_service.dart';
import '../../activities/pages/add_activity_page.dart';
import '../../activities/pages/activity_list_page.dart';
import '../../activities/services/activity_service.dart';
import '../../challenges/pages/challenge_list_page.dart';
import '../../leaderboard/pages/leaderboard_page.dart';
import '../../profile/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityService _activityService = ActivityService();

  late Future<UserModel?> _userFuture;
  late Stream<List<ActivityModel>> _activitiesStream;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getCurrentUserData();
    _activitiesStream = _activityService.getUserActivitiesStream();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _userFuture = _authService.getCurrentUserData();
      _activitiesStream = _activityService.getUserActivitiesStream();
    });
  }

  void _goToAddActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddActivityPage()),
    ).then((_) => _refreshData());
  }

  void _goToChallengePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChallengeListPage(showAppBar: true),
      ),
    );
  }

  void _goToLeaderboardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
    );
  }

  void _goToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    ).then((_) => _refreshData());
  }

  String _getInitial(String name) {
    if (name.trim().isEmpty) return 'U';
    return name.trim()[0].toUpperCase();
  }

  IconData _getSportIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('run')) return Icons.directions_run_rounded;
    if (t.contains('gym') || t.contains('workout'))
      return Icons.fitness_center_rounded;
    if (t.contains('cycl') || t.contains('sepeda'))
      return Icons.directions_bike_rounded;
    if (t.contains('swim') || t.contains('renang')) return Icons.pool_rounded;
    if (t.contains('yoga')) return Icons.self_improvement_rounded;
    return Icons.fitness_center_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: LoadingWidget(message: 'Memuat dashboard...'),
          );
        }

        final user = snapshot.data;
        final name = user?.name.isNotEmpty == true
            ? user!.name
            : 'FitNova User';

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.softCard,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Clean Header
                      _buildHeader(name, user),
                      const SizedBox(height: 24),

                      // 2. Hero Summary Card (Weekly Progress)
                      _buildHeroSummaryCard(user),
                      const SizedBox(height: 24),

                      // 3. Feature Shortcut Grid
                      _buildShortcutGrid(),
                      const SizedBox(height: 28),

                      // 4. Challenge Banner
                      _buildChallengeBanner(),
                      const SizedBox(height: 28),

                      // 5. Recent Activities
                      _buildRecentActivitiesSection(),
                      const SizedBox(height: 28),

                      // 6. Weekly Insight Card
                      _buildWeeklyInsightCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, UserModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _goToProfilePage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSoft, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                  child: Text(
                    _getInitial(name),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stay healthy, stay fit!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.softCard,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Belum ada notifikasi baru.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSummaryCard(UserModel? user) {
    final double weeklyTargetMin = 150.0;
    final int currentDuration = user?.totalDuration ?? 0;
    final double progress = (currentDuration / weeklyTargetMin).clamp(0.0, 1.0);

    return SoftGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _goToAddActivityPage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add Activity',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$currentDuration mins',
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target: 150 mins per week',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ProgressBar(
            value: progress,
            progressColor: AppColors.primaryGreen,
            backgroundColor: AppColors.darkGreen.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${user?.totalActivities ?? 0} activities',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${user?.totalCalories ?? 0} kcal',
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

  Widget _buildShortcutGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FeatureIconButton(
            icon: Icons.add_rounded,
            label: 'Add Activity',
            onTap: _goToAddActivityPage,
          ),
        ),
        Expanded(
          child: FeatureIconButton(
            icon: Icons.emoji_events_rounded,
            label: 'Challenge',
            onTap: _goToChallengePage,
          ),
        ),
        Expanded(
          child: FeatureIconButton(
            icon: Icons.leaderboard_rounded,
            label: 'Leaderboard',
            onTap: _goToLeaderboardPage,
          ),
        ),
        Expanded(
          child: FeatureIconButton(
            icon: Icons.person_rounded,
            label: 'Profile',
            onTap: _goToProfilePage,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeBanner() {
    return GestureDetector(
      onTap: _goToChallengePage,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.mediumGreen, AppColors.borderSoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.borderSoft, width: 1.0),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Take a New Challenge',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Push your limit this week',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Join Now',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Switch tab is done by changing tab or pushing ActivityListPage.
                // We'll push ActivityListPage to keep user flow seamless and direct.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivityListPage()),
                );
              },
              child: Text(
                'See All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ActivityModel>>(
          stream: _activitiesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
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
              );
            }

            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return SoftCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No recent activities. Start moving!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }

            final recent = activities.take(3).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final activity = recent[index];
                return SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getSportIcon(activity.sportType),
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.sportType,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormatter.formatDate(activity.activityDate),
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
                            '${activity.duration} mins',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activity.calories} kcal',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyInsightCard() {
    return SoftCard(
      color: AppColors.cardSecondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.softMint,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Insight',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.softMint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consistency is key! Just 10-15 minutes of light exercise daily helps maintain your activity streak and build a healthier habit.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
