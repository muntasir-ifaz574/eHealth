import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class _VoiceCommand {
  const _VoiceCommand({
    required this.icon,
    required this.phrases,
    required this.result,
  });

  final IconData icon;
  final List<String> phrases;
  final String result;
}

const _commands = [
  _VoiceCommand(
    icon: Icons.mic_off,
    phrases: ['stop listening', 'stop', 'cancel', 'never mind'],
    result: 'Stops listening',
  ),
  _VoiceCommand(
    icon: Icons.emergency,
    phrases: ['emergency', 'call 999', 'call ambulance', 'help me'],
    result: 'Dials the emergency number',
  ),
  _VoiceCommand(
    icon: Icons.call_end,
    phrases: ['end call', 'hang up', 'disconnect call', 'leave call'],
    result: 'Ends the current video call',
  ),
  _VoiceCommand(
    icon: Icons.mic_off,
    phrases: ['mute', 'unmute', 'turn on/off microphone'],
    result: 'Mutes/unmutes the microphone during a call',
  ),
  _VoiceCommand(
    icon: Icons.videocam_off,
    phrases: ['turn on/off camera', 'switch camera', 'flip camera'],
    result: 'Toggles or flips the camera during a call',
  ),
  _VoiceCommand(
    icon: Icons.map,
    phrases: ['show map', 'hospital map', 'map view', 'show hospitals on map'],
    result: 'Opens the hospital map',
  ),
  _VoiceCommand(
    icon: Icons.local_hospital,
    phrases: [
      'find hospital',
      'nearby hospital',
      'hospitals near me',
      'find a hospital',
    ],
    result: 'Opens nearby hospitals',
  ),
  _VoiceCommand(
    icon: Icons.medical_services,
    phrases: [
      'list of doctors',
      'show doctors',
      'available doctors',
      'open doctors',
    ],
    result: 'Opens the doctor list',
  ),
  _VoiceCommand(
    icon: Icons.videocam,
    phrases: [
      'call doctor <name>',
      'video call <name>',
      'talk to doctor <name>',
      'call <name/specialization>',
    ],
    result:
        'Opens the booking screen for that doctor (fuzzy-matched by name or '
        'specialization, e.g. "call a cardiologist"; defaults to the first '
        'bookable doctor if nothing matches)',
  ),
  _VoiceCommand(
    icon: Icons.event_note,
    phrases: [
      'my appointments',
      'show appointments',
      'appointment list',
      'upcoming appointments',
    ],
    result: 'Opens your appointments',
  ),
  _VoiceCommand(
    icon: Icons.person,
    phrases: ['my profile', 'open profile', 'show profile'],
    result: 'Opens your profile',
  ),
  _VoiceCommand(
    icon: Icons.health_and_safety,
    phrases: ['symptom checker', 'check my symptoms', 'check symptoms'],
    result: 'Opens the symptom checker',
  ),
  _VoiceCommand(
    icon: Icons.show_chart,
    phrases: ['health progress', 'my progress', 'show my progress'],
    result: 'Opens your health progress',
  ),
  _VoiceCommand(
    icon: Icons.replay,
    phrases: ['repeat', 'say again', 'what did you say'],
    result: "Repeats the assistant's last spoken response",
  ),
  _VoiceCommand(
    icon: Icons.help_outline,
    phrases: ['what can i say', 'voice commands', 'help'],
    result: 'Opens this screen',
  ),
  _VoiceCommand(
    icon: Icons.home,
    phrases: ['home', 'go home', 'main screen', 'dashboard'],
    result: 'Goes to the Home tab',
  ),
];

class VoiceCommandsScreen extends StatelessWidget {
  const VoiceCommandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Commands')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Text(
            'Tap the mic button (draggable, on every screen) and say any of '
            'the phrases below. Recognition matches by substring, so full '
            'sentences containing them work too.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final command in _commands)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusButton,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        command.icon,
                        color: AppColors.electricBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            command.phrases.join('  /  '),
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(command.result, style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
