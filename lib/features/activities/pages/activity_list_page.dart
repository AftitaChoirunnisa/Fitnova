// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
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

  void _goToAddActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddActivityPage(),
      ),
    );
  }

  void _goToEditActivityPage(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityPage(
          activity: activity,
        ),
      ),
    );
  }

  void _goToDetailPage(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDetailPage(
          activityId: activity.id,
        ),
      ),
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
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
        const SnackBar(
          content: Text('Aktivitas berhasil dihapus.'),
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

  List<ActivityModel> _filterActivities(List<ActivityModel> activities) {
    return activities.where((activity) {
      final matchesSearch = activity.sportType
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          activity.note.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'Semua'
          ? true
          : activity.sportType == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ActivityModel>>(
        stream: _activityService.getUserActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              message: 'Memuat aktivitas...',
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          }

          final activities = snapshot.data ?? [];
          final filteredActivities = _filterActivities(activities);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, activities),
                ),
                SliverToBoxAdapter(
                  child: _buildSearchAndFilter(),
                ),
                if (activities.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.fitness_center_rounded,
                      title: 'Belum ada aktivitas',
                      message:
                          'Tambahkan aktivitas olahraga pertamamu agar progress fitness kamu mulai tercatat.',
                      buttonText: 'Tambah Aktivitas',
                      onPressed: _goToAddActivityPage,
                    ),
                  )
                else if (filteredActivities.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: 'Data tidak ditemukan',
                      message:
                          'Coba gunakan kata kunci atau filter olahraga yang berbeda.',
                      buttonText: 'Reset Filter',
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'Semua';
                        });
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverList.separated(
                      itemCount: filteredActivities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final activity = filteredActivities[index];

                        return _buildActivityCard(context, activity);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddActivityPage,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<ActivityModel> activities,
  ) {
    final totalDuration = activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.duration,
    );

    final totalCalories = activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.calories,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 38,
            ),
            const SizedBox(height: 16),
            Text(
              'Aktivitas Olahraga',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${activities.length} aktivitas • $totalDuration menit • $totalCalories kkal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Cari aktivitas atau catatan...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    ActivityModel activity,
  ) {
    final sportColor = _getSportColor(activity.sportType);

    return Card(
      child: InkWell(
        onTap: () => _goToDetailPage(activity),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'activity-icon-${activity.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: sportColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _getSportIcon(activity.sportType),
                      color: sportColor,
                      size: 30,
                    ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDate(activity.activityDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMiniInfo(
                          Icons.timer_outlined,
                          '${activity.duration} menit',
                        ),
                        const SizedBox(width: 10),
                        _buildMiniInfo(
                          Icons.local_fire_department_outlined,
                          '${activity.calories} kkal',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'detail') {
                    _goToDetailPage(activity);
                  } else if (value == 'edit') {
                    _goToEditActivityPage(activity);
                  } else if (value == 'delete') {
                    _deleteActivity(activity);
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined),
                          SizedBox(width: 8),
                          Text('Detail'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      title: 'Gagal memuat aktivitas',
      message: error,
      buttonText: 'Coba Lagi',
      onPressed: () {
        setState(() {});
      },
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