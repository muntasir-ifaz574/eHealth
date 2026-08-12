import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';
import 'package:equatable/equatable.dart';

class FirstAid extends Equatable {
  const FirstAid({required this.code, required this.title, required this.steps});

  final String code;
  final String title;
  final List<String> steps;

  @override
  List<Object?> get props => [code, title, steps];
}

/// The response to `POST prompt/create-backup`. For symptom-like input this
/// carries a full triage/first-aid assessment; for casual/non-symptom input
/// (e.g. "Hi") the backend instead returns just a plain conversational
/// [message] with no triage data at all — every field but [message] is
/// therefore optional.
class PromptResult extends Equatable {
  const PromptResult({
    this.generatedBy,
    this.triageLevel,
    this.firstAid,
    this.hospitalLookupNeeded,
    this.message,
  });

  final String? generatedBy;
  final TriageLevel? triageLevel;
  final FirstAid? firstAid;
  final bool? hospitalLookupNeeded;
  final String? message;

  @override
  List<Object?> get props => [generatedBy, triageLevel, firstAid, hospitalLookupNeeded, message];
}
