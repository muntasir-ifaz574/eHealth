import 'package:ehealth/features/voice_assistant/presentation/widgets/voice_mic_button.dart';
import 'package:flutter/material.dart';

const _buttonSize = 56.0;
const _margin = 8.0;

/// Wraps [VoiceMicButton] so the user can drag it anywhere on screen instead
/// of it sitting in one fixed spot. Position is kept in memory for the
/// current app session and re-clamped to the screen bounds on every build
/// (so rotating the device, for instance, can't leave it off-screen).
class DraggableMicButton extends StatefulWidget {
  const DraggableMicButton({super.key});

  @override
  State<DraggableMicButton> createState() => _DraggableMicButtonState();
}

class _DraggableMicButtonState extends State<DraggableMicButton> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxX = size.width - _buttonSize - _margin;
    final maxY = size.height - _buttonSize - _margin;

    final defaultPosition = Offset(maxX, size.height - _buttonSize - 88);
    final current = _position ?? defaultPosition;
    final clamped = Offset(current.dx.clamp(_margin, maxX), current.dy.clamp(_margin, maxY));

    return Positioned(
      left: clamped.dx,
      top: clamped.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _position = clamped + details.delta),
        child: const VoiceMicButton(),
      ),
    );
  }
}
