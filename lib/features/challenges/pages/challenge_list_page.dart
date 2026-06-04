// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/challenge_model.dart';
import '../services/challenge_service.dart';
import 'add_challenge_page.dart';
import 'challenge_detail_page.dart';
import 'my_challenge_page.dart';

class ChallengeListPage extends StatefulWidget {
  final bool showAppBar;

  const ChallengeListPage({super.key, this.showAppBar = true});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  final ChallengeService _challengeService = ChallengeService();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Cardio',
    'Strength',
    'Yoga',
    'Running',
    'Cycling',
    'General Fitness',
  ];

  void _goToAddChallengePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChallengePage()),
    );
  }

  void _goToMyChallengePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyChallengePage()),
    );
  }

  void _goToDetailPage(ChallengeModel challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailPage(challengeId: challenge.id),
      ),
    );
  }

  List<ChallengeModel> _filterChallenges(List<ChallengeModel> challenges) {
    return challenges.where((challenge) {
      final matchesSearch =
          challenge.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          challenge.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesCategory = _selectedCategory == 'Semua'
          ? true
          : challenge.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Challenge')) : null,
      body: StreamBuilder<List<ChallengeModel>>(
        stream: _challengeService.getChallengesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Memuat challenge...');
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat challenge',
              message: snapshot.error.toString(),
              buttonText: 'Coba Lagi',
              onPressed: () => setState(() {}),
            );
          }

          final challenges = snapshot.data ?? [];
          final filteredChallenges = _filterChallenges(challenges);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, challenges.length),
              ),
              SliverToBoxAdapter(child: _buildSearchAndFilter()),
              if (challenges.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    icon: Icons.emoji_events_rounded,
                    title: 'Belum ada challenge',
                    message:
                        'Buat challenge pertama agar pengguna bisa ikut olahraga bersama.',
                    buttonText: 'Buat Challenge',
                    onPressed: _goToAddChallengePage,
                  ),
                )
              else if (filteredChallenges.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'Challenge tidak ditemukan',
                    message: 'Coba kata kunci atau kategori lain.',
                    buttonText: 'Reset Filter',
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'Semua';
                      });
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: SliverList.separated(
                    itemCount: filteredChallenges.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final challenge = filteredChallenges[index];

                      return _buildChallengeCard(context, challenge);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddChallengePage,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalChallenge) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 38,
            ),
            const SizedBox(height: 16),
            Text(
              'Fitness Challenge',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalChallenge challenge tersedia untuk meningkatkan motivasi olahraga.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _goToMyChallengePage,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Challenge Saya'),
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
              hintText: 'Cari challenge...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildChallengeCard(BuildContext context, ChallengeModel challenge) {
    return Card(
      child: InkWell(
        onTap: () => _goToDetailPage(challenge),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'challenge-icon-${challenge.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.secondary,
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
                      challenge.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${challenge.targetDuration} menit • ${DateFormatter.formatDate(challenge.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
