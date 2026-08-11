import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_controller.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global floating mic button — tap to start/stop voice control. Placed in
/// [AppShell] so every screen using the shell can be driven by voice.
class VoiceMicButton extends ConsumerWidget {
  const VoiceMicButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceAssistantControllerProvider);
    final isListening = state.status == VoiceStatus.listening;
    final isBusy = state.status == VoiceStatus.initializing || state.status == VoiceStatus.processing;

    return FloatingActionButton(
      heroTag: 'voiceMicButton',
      backgroundColor: isListening ? Colors.redAccent : null,
      onPressed: isBusy
          ? null
          : () => ref.read(voiceAssistantControllerProvider.notifier).toggleListening(),
      tooltip: isListening ? 'Stop voice command' : 'Speak a command',
      child: isBusy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(isListening ? Icons.mic : Icons.mic_none),
    );
  }
}
