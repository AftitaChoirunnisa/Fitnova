// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/activity_model.dart';
import '../services/activity_service.dart';
import 'activity_detail_page.dart';
import 'add_activity_page.dart';

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  final ActivityService _activityService = ActivityService();

  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Lari',
    'Jalan Kaki',
    'Bersepeda',
    'Renang',
    'Gym',
    'Yoga',
    'Workout Rumah',
  ];

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'Semua':
        return 'All';
      case 'Lari':
        return 'Running';
      case 'Jalan Kaki':
        return 'Walking';
      case 'Bersepeda':
        return 'Cycling';
      case 'Renang':
        return 'Swimming';
      case 'Gym':
        return 'Gym';
      case 'Yoga':
        return 'Yoga';
      case 'Workout Rumah':
        return 'Workout';
      default:
        return filter;
    }
  }

  void _goToAddActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddActivityPage()),
    );
  }

  void _goToEditActivityPage(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddActivityPage(activity: activity)),
    );
  }

  void _goToDetailPage(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDetailPage(activityId: activity.id),
      ),
    );
  }

  Future<void> _deleteActivity(ActivityModel activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.softCard,
          title: Text('Hapus Aktivitas?', style: AppTextStyles.headingSmall),
          content: Text(
            'Aktivitas ${activity.sportType} akan dihapus permanen.',
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

    if (confirm != true) {
      return;
    }

    try {
      await _activityService.deleteActivity(activity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas berhasil dihapus.')),
      );
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

  List<ActivityModel> _filterActivities(List<ActivityModel> activities) {
    return activities.where((activity) {
      final matchesSearch =
          activity.sportType.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          activity.note.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'Semua'
          ? true
          : activity.sportType == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A16),
      body: SafeArea(
        child: StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getUserActivitiesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(message: 'Memuat aktivitas...');
            }

            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error.toString());
            }

            final activities = snapshot.data ?? [];
            final filteredActivities = _filterActivities(activities);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(activities),
                _buildSearchAndFilter(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    color: AppColors.primaryGreen,
                    backgroundColor: AppColors.softCard,
                    child: filteredActivities.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 350,
                              child: _buildEmptyState(),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                            itemCount: filteredActivities.length,
                            itemBuilder: (context, index) {
                              final activity = filteredActivities[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildActivityCard(context, activity),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
          onPressed: _goToAddActivityPage,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.darkGreen,
          shape: const CircleBorder(),
          elevation: 2,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF103C32),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF245B4B)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 32,
                color: Color(0xFF4CD58A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Data tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF2FFF8),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Coba gunakan kata kunci atau filter olahraga yang berbeda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA8BDB4),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<ActivityModel> activities) {
    final totalDuration = activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.duration,
    );

    final totalCalories = activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.calories,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities',
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Track your daily movement',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat('${activities.length}', 'Activities'),
                Container(width: 1, height: 24, color: AppColors.borderSoft),
                _buildHeaderStat('$totalDuration mins', 'Duration'),
                Container(width: 1, height: 24, color: AppColors.borderSoft),
                _buildHeaderStat('$totalCalories kcal', 'Calories'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 4, bottom: 6),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search activity or note...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.darkGreen,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSoft),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSoft),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 36,
            margin: const EdgeInsets.only(top: 2, bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return ChoiceChip(
                  label: Text(_getFilterLabel(filter)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  backgroundColor: AppColors.softCard,
                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                  labelStyle: AppTextStyles.titleMedium.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.borderSoft,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _goToDetailPage(activity),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'activity-icon-${activity.id}',
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Icon(
                    _getSportIcon(activity.sportType),
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
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
                    if (activity.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        activity.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${activity.duration} mins',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
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
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                color: AppColors.softCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'detail') {
                    _goToDetailPage(activity);
                  } else if (value == 'edit') {
                    _goToEditActivityPage(activity);
                  } else if (value == 'delete') {
                    _deleteActivity(activity);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        const Icon(Icons.visibility_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('Detail', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('Edit', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat aktivitas',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
