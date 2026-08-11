import 'package:ehealth/core/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppTab { home, hospitals, doctors }

/// Shared scaffold for the three top-level tabs (Home / Hospitals / Doctors)
/// so they share one bottom navigation bar. Screens that aren't a tab
/// (detail, map, call, voice assistant) use a plain [Scaffold] instead.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.currentTab,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final AppTab currentTab;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab.index,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital),
            label: 'Hospitals',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (AppTab.values[index]) {
      case AppTab.home:
        context.goNamed(RouteNames.home);
      case AppTab.hospitals:
        context.goNamed(RouteNames.hospitalList);
      case AppTab.doctors:
        context.goNamed(RouteNames.doctorList);
    }
  }
}
