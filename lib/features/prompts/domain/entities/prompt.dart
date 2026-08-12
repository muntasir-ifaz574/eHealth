import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';
import 'package:equatable/equatable.dart';

class Prompt extends Equatable {
  const Prompt({
    required this.id,
    required this.generatedBy,
    this.text,
    this.triageLevel,
    this.firstAidString,
    this.hospitalLookupNeeded,
    this.createdAt,
  });

  final String id;
  final String generatedBy;
  final String? text;
  final TriageLevel? triageLevel;
  final String? firstAidString;
  final bool? hospitalLookupNeeded;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, generatedBy, text, triageLevel, firstAidString, hospitalLookupNeeded, createdAt];
}

class PromptPage extends Equatable {
  const PromptPage({required this.items, this.nextCursor});

  final List<Prompt> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
