import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_controller.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_state.dart';
import 'package:ehealth/features/voice_assistant/presentation/widgets/voice_mic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceAssistantControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(_statusLabel(state.status), style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOU SAID', style: AppTextStyles.labelCaps),
                    const SizedBox(height: 4),
                    Text(
                      state.transcript.isEmpty ? '—' : state.transcript,
                      style: AppTextStyles.headlineMd,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (state.lastResponse != null) ...[
                      Text('ASSISTANT', style: AppTextStyles.labelCaps),
                      const SizedBox(height: 4),
                      Text(state.lastResponse!, style: AppTextStyles.bodyMd),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(state.errorMessage!, style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Try saying: "find hospital", "show map", '
                      '"call doctor <name>", "talk to doctor", "emergency", '
                      '"go home".',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const VoiceMicButton(),
          ],
        ),
      ),
    );
  }

  String _statusLabel(VoiceStatus status) {
    return switch (status) {
      VoiceStatus.idle => 'Tap the mic and speak a command',
      VoiceStatus.initializing => 'Starting up…',
      VoiceStatus.listening => 'Listening…',
      VoiceStatus.processing => 'Understanding…',
      VoiceStatus.speaking => 'Speaking…',
      VoiceStatus.error => 'Something went wrong',
    };
  }
}
