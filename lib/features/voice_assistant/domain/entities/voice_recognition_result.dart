import 'package:equatable/equatable.dart';

class VoiceRecognitionResult extends Equatable {
  const VoiceRecognitionResult({
    required this.text,
    required this.isFinal,
    this.confidence = 1.0,
  });

  final String text;
  final bool isFinal;
  final double confidence;

  @override
  List<Object?> get props => [text, isFinal, confidence];
}
