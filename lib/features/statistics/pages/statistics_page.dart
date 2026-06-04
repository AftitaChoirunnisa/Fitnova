import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/activity_model.dart';
import '../../activities/services/activity_service.dart';

class StatisticsPage extends StatefulWidget {
  final bool showAppBar;

  const StatisticsPage({super.key, this.showAppBar = true});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final ActivityService _activityService = ActivityService();

  static const int weeklyTargetDuration = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Statistik Progress'))
          : null,
      body: StreamBuilder<List<ActivityModel>>(
        stream: _activityService.getUserActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Memuat statistik...');
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat statistik',
              message: snapshot.error.toString(),
              buttonText: 'Coba Lagi',
              onPressed: () {
                setState(() {});
              },
            );
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.insert_chart_outlined_rounded,
              title: 'Belum ada statistik',
              message:
                  'Tambahkan aktivitas olahraga terlebih dahulu agar statistik progress kamu bisa ditampilkan.',
            );
          }

          final totalActivities = activities.length;
          final totalDuration = _calculateTotalDuration(activities);
          final totalCalories = _calculateTotalCalories(activities);
          final currentStreak = _calculateCurrentStreak(activities);
          final weeklyDuration = _calculateThisWeekDuration(activities);
          final weeklyProgress = (weeklyDuration / weeklyTargetDuration).clamp(
            0.0,
            1.0,
          );
          final insight = _generateInsight(activities);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderCard(context),
                const SizedBox(height: 16),
                _buildSummaryGrid(
                  context,
                  totalActivities: totalActivities,
                  totalDuration: totalDuration,
                  totalCalories: totalCalories,
                  currentStreak: currentStreak,
                ),
                const SizedBox(height: 16),
                _buildWeeklyProgressCard(
                  context,
                  weeklyDuration: weeklyDuration,
                  weeklyProgress: weeklyProgress,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(context, insight),
                const SizedBox(height: 16),
                _buildSevenDaysChartCard(context, activities),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
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
              Icons.query_stats_rounded,
              size: 112,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.insert_chart_rounded,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(height: 16),
              Text(
                'Statistik FitNova',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pantau progress olahraga, durasi, kalori, streak, dan insight kebiasaanmu.',
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

  Widget _buildSummaryGrid(
    BuildContext context, {
    required int totalActivities,
    required int totalDuration,
    required int totalCalories,
    required int currentStreak,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _buildSummaryCard(
          context,
          icon: Icons.fitness_center_rounded,
          title: 'Aktivitas',
          value: '$totalActivities',
          subtitle: 'total',
          color: AppColors.primary,
        ),
        _buildSummaryCard(
          context,
          icon: Icons.timer_outlined,
          title: 'Durasi',
          value: '$totalDuration',
          subtitle: 'menit',
          color: AppColors.secondary,
        ),
        _buildSummaryCard(
          context,
          icon: Icons.local_fire_department_rounded,
          title: 'Kalori',
          value: '$totalCalories',
          subtitle: 'kkal',
          color: AppColors.warning,
        ),
        _buildSummaryCard(
          context,
          icon: Icons.bolt_rounded,
          title: 'Streak',
          value: '$currentStreak',
          subtitle: 'hari',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildWeeklyProgressCard(
    BuildContext context, {
    required int weeklyDuration,
    required double weeklyProgress,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              icon: Icons.track_changes_rounded,
              title: 'Progress Target Mingguan',
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: weeklyProgress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      color: value >= 1 ? AppColors.success : AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$weeklyDuration / $weeklyTargetDuration menit',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(value * 100).toStringAsFixed(0)}% dari target olahraga mingguan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSevenDaysChartCard(
    BuildContext context,
    List<ActivityModel> activities,
  ) {
    final chartData = _getLastSevenDaysDuration(activities);
    final maxY = _getMaxChartY(chartData);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              icon: Icons.bar_chart_rounded,
              title: 'Aktivitas 7 Hari Terakhir',
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 230,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: AppColors.border, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              chartData[index].dayLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.duration.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Grafik menunjukkan total durasi olahraga per hari dalam satuan menit.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  int _calculateTotalDuration(List<ActivityModel> activities) {
    return activities.fold<int>(
      0,
      (total, activity) => total + activity.duration,
    );
  }

  int _calculateTotalCalories(List<ActivityModel> activities) {
    return activities.fold<int>(
      0,
      (total, activity) => total + activity.calories,
    );
  }

  int _calculateThisWeekDuration(List<ActivityModel> activities) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return activities
        .where((activity) {
          final date = DateTime(
            activity.activityDate.year,
            activity.activityDate.month,
            activity.activityDate.day,
          );

          return date.isAtSameMomentAs(startDate) || date.isAfter(startDate);
        })
        .fold<int>(0, (total, activity) => total + activity.duration);
  }

  int _calculatePreviousWeekDuration(List<ActivityModel> activities) {
    final now = DateTime.now();

    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(
      startOfThisWeek.year,
      startOfThisWeek.month,
      startOfThisWeek.day,
    );

    final previousWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    return activities
        .where((activity) {
          final date = DateTime(
            activity.activityDate.year,
            activity.activityDate.month,
            activity.activityDate.day,
          );

          return (date.isAtSameMomentAs(previousWeekStart) ||
                  date.isAfter(previousWeekStart)) &&
              (date.isAtSameMomentAs(previousWeekEnd) ||
                  date.isBefore(previousWeekEnd));
        })
        .fold<int>(0, (total, activity) => total + activity.duration);
  }

  int _calculateCurrentStreak(List<ActivityModel> activities) {
    if (activities.isEmpty) {
      return 0;
    }

    final uniqueDays = activities
        .map(
          (activity) => DateTime(
            activity.activityDate.year,
            activity.activityDate.month,
            activity.activityDate.day,
          ),
        )
        .toSet();

    final today = DateTime.now();
    DateTime checkedDay = DateTime(today.year, today.month, today.day);

    int streak = 0;

    while (uniqueDays.contains(checkedDay)) {
      streak++;
      checkedDay = checkedDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateDaysSinceLastActivity(List<ActivityModel> activities) {
    if (activities.isEmpty) {
      return 999;
    }

    final sortedActivities = [...activities]
      ..sort((a, b) => b.activityDate.compareTo(a.activityDate));

    final lastActivityDate = sortedActivities.first.activityDate;
    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final lastOnly = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );

    return todayOnly.difference(lastOnly).inDays;
  }

  String _generateInsight(List<ActivityModel> activities) {
    final totalDuration = _calculateTotalDuration(activities);
    final currentStreak = _calculateCurrentStreak(activities);
    final daysSinceLastActivity = _calculateDaysSinceLastActivity(activities);
    final thisWeekDuration = _calculateThisWeekDuration(activities);
    final previousWeekDuration = _calculatePreviousWeekDuration(activities);

    if (daysSinceLastActivity >= 3) {
      return 'Kamu belum mencatat aktivitas selama beberapa hari. Coba mulai lagi dengan olahraga ringan 10 menit hari ini.';
    }

    if (currentStreak >= 3) {
      return 'Streak kamu bagus! Kamu sudah aktif beberapa hari berturut-turut. Pertahankan agar kebiasaan olahraga semakin terbentuk.';
    }

    if (thisWeekDuration > previousWeekDuration && previousWeekDuration > 0) {
      return 'Progress kamu meningkat minggu ini dibanding minggu sebelumnya. Pertahankan konsistensinya.';
    }

    if (totalDuration < 60) {
      return 'Total durasi olahraga kamu masih rendah. Coba tambah jalan kaki, stretching, atau workout ringan 10–15 menit.';
    }

    if (thisWeekDuration >= weeklyTargetDuration) {
      return 'Target mingguan kamu sudah tercapai. Bagus! Tetap jaga ritme olahraga dan beri tubuh waktu istirahat yang cukup.';
    }

    return 'Progress kamu sudah mulai terbentuk. Lanjutkan olahraga secara konsisten agar hasilnya semakin terlihat.';
  }

  List<_DailyDuration> _getLastSevenDaysDuration(
    List<ActivityModel> activities,
  ) {
    final now = DateTime.now();
    final result = <_DailyDuration>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayOnly = DateTime(day.year, day.month, day.day);

      final totalDuration = activities
          .where((activity) {
            final activityDay = DateTime(
              activity.activityDate.year,
              activity.activityDate.month,
              activity.activityDate.day,
            );

            return activityDay == dayOnly;
          })
          .fold<int>(0, (total, activity) => total + activity.duration);

      result.add(
        _DailyDuration(
          dayLabel: _getDayLabel(day.weekday),
          duration: totalDuration,
        ),
      );
    }

    return result;
  }

  double _getMaxChartY(List<_DailyDuration> chartData) {
    if (chartData.isEmpty) {
      return 100;
    }

    final maxDuration = chartData
        .map((item) => item.duration)
        .fold<int>(0, (max, value) => value > max ? value : max);

    if (maxDuration <= 30) {
      return 30;
    }

    return (maxDuration + 20).toDouble();
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Min';
      default:
        return '-';
    }
  }
}

class _DailyDuration {
  final String dayLabel;
  final int duration;

  _DailyDuration({required this.dayLabel, required this.duration});
}
