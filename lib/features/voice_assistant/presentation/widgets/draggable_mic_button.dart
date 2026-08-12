import 'package:ehealth/features/voice_assistant/presentation/widgets/voice_mic_button.dart';
import 'package:flutter/material.dart';

const _buttonSize = 56.0;
const _margin = 8.0;

double _safeClamp(double value, double upper) {
  if (upper < _margin) return _margin;
  return value.clamp(_margin, upper);
}

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
    final clamped = Offset(
      _safeClamp(current.dx, maxX),
      _safeClamp(current.dy, maxY),
    );

    return Positioned(
      left: clamped.dx,
      top: clamped.dy,
      child: GestureDetector(
        onPanUpdate: (details) =>
            setState(() => _position = clamped + details.delta),
        child: const VoiceMicButton(),
      ),
    );
  }
}
