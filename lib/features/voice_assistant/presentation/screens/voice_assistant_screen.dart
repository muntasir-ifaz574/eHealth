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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(_statusLabel(state.status), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You said', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      state.transcript.isEmpty ? '—' : state.transcript,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    if (state.lastResponse != null) ...[
                      Text('Assistant', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(state.lastResponse!),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Try saying: "find hospital", "show map", '
                      '"call doctor <name>", "talk to doctor", "emergency", '
                      '"go home".',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
