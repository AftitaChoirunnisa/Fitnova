import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fitness_bottom_nav.dart';
import '../../activities/pages/activity_list_page.dart';
import '../../challenges/pages/challenge_list_page.dart';
import '../../leaderboard/pages/leaderboard_page.dart';
import '../../profile/pages/profile_page.dart';
import 'home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ActivityListPage(),
    ChallengeListPage(showAppBar: false),
    LeaderboardPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepBackground, AppColors.darkGreen],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: FitnessBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
