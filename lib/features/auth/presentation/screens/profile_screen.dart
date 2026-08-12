import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.userName ?? ''),
              subtitle: Text(user?.userEmail ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileAction(
            icon: Icons.event_note,
            title: 'My Appointments',
            onTap: () => context.pushNamed(RouteNames.appointmentList),
          ),
          _ProfileAction(
            icon: Icons.health_and_safety,
            title: 'Symptom Checker',
            onTap: () => context.pushNamed(RouteNames.symptomChecker),
          ),
          _ProfileAction(
            icon: Icons.show_chart,
            title: 'Health Progress',
            onTap: () => context.pushNamed(RouteNames.healthProgress),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.goNamed(RouteNames.login);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
