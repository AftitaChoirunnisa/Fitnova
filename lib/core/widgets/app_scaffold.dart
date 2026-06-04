import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? appBarTitle;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final List<Widget>? appBarActions;
  final bool resizeToAvoidBottomInset;
  final Widget? leading;
  final PreferredSizeWidget? appBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBarTitle,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.appBarActions,
    this.resizeToAvoidBottomInset = true,
    this.leading,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, AppColors.backgroundAlt],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar:
            appBar ??
            (appBarTitle != null
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: false,
                    leading: leading,
                    title: Text(
                      appBarTitle!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    actions: appBarActions,
                  )
                : null),
        body: SafeArea(child: body),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
