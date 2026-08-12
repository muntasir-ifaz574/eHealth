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

/// The response to `POST prompt/create-backup` — a triaged first-aid result
/// for the symptom text the user just submitted.
class PromptResult extends Equatable {
  const PromptResult({
    required this.generatedBy,
    required this.triageLevel,
    required this.firstAid,
    required this.hospitalLookupNeeded,
    this.message,
  });

  final String generatedBy;
  final TriageLevel triageLevel;
  final FirstAid firstAid;
  final bool hospitalLookupNeeded;
  final String? message;

  @override
  List<Object?> get props => [generatedBy, triageLevel, firstAid, hospitalLookupNeeded, message];
}
