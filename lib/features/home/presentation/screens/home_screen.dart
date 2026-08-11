import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: AppTab.home,
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Say "find hospital", "call doctor", or tap the mic — the app '
            'can be fully controlled by voice.',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          _QuickAction(
            icon: Icons.local_hospital,
            title: 'Nearby Hospitals',
            subtitle: 'Find hospitals close to you with contact numbers',
            onTap: () => context.goNamed(RouteNames.hospitalList),
          ),
          _QuickAction(
            icon: Icons.medical_services,
            title: 'Talk to a Doctor',
            subtitle: 'Start a live video consultation',
            onTap: () => context.goNamed(RouteNames.doctorList),
          ),
          _QuickAction(
            icon: Icons.mic,
            title: 'Voice Assistant',
            subtitle: 'View voice command transcript & help',
            onTap: () => context.pushNamed(RouteNames.voiceAssistant),
          ),
          _QuickAction(
            icon: Icons.emergency,
            title: 'Emergency Call',
            subtitle: 'Dial ${AppConstants.emergencyServiceNumber} immediately',
            color: Colors.red,
            onTap: () => dialPhoneNumber(AppConstants.emergencyServiceNumber),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
