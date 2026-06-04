import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/soft_gradient_card.dart';
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

  String _getCategoryLabel(String category) {
    if (category == 'Semua') return 'All';
    return category;
  }

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
    return AppScaffold(
      leading: widget.showAppBar
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      appBarTitle: widget.showAppBar ? 'Challenges' : null,
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(challenges.length),
              _buildSearchAndFilter(),
              Expanded(
                child: filteredChallenges.isEmpty
                    ? (challenges.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.emoji_events_rounded,
                              title: 'Belum ada challenge',
                              message:
                                  'Buat challenge pertama agar pengguna bisa ikut olahraga bersama.',
                              buttonText: 'Buat Challenge',
                              onPressed: _goToAddChallengePage,
                            )
                          : EmptyStateWidget(
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
                            ))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddChallengePage,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.darkGreen,
        shape: const CircleBorder(),
        elevation: 2,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader(int totalChallenge) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: SoftGradientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                GestureDetector(
                  onTap: _goToMyChallengePage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.list_alt_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'My Challenges',
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
            const SizedBox(height: 20),
            Text(
              'Fitness Challenge',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$totalChallenge challenges available to test your limits and keep you motivated.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search challenge...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.darkGreen,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return ChoiceChip(
                  label: Text(_getCategoryLabel(category)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: AppColors.softCard,
                  selectedColor: AppColors.primaryGreen.withOpacity(0.12),
                  labelStyle: AppTextStyles.titleMedium.copyWith(
                    fontSize: 13,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, ChallengeModel challenge) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _goToDetailPage(challenge),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'challenge-icon-${challenge.id}',
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
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
                      challenge.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${challenge.targetDuration} mins • Ends ${DateFormatter.formatDate(challenge.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
