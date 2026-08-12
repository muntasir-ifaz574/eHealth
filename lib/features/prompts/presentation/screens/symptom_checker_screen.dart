import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:collection/collection.dart';
import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/core/widgets/pill_chip.dart';
import 'package:ehealth/features/hospital/presentation/providers/hospital_providers.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';
import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';
import 'package:ehealth/features/prompts/domain/usecases/get_prompts.dart';
import 'package:ehealth/features/prompts/presentation/providers/prompts_providers.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isSubmitting = false;
  final List<_Turn> _turns = [];

  final List<Prompt> _history = [];
  String? _nextCursor;
  bool _isLoadingOlder = false;

  @override
  void initState() {
    super.initState();
    _loadOlder();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOlder({String? afterCursor}) async {
    setState(() => _isLoadingOlder = true);
    final result = await ref
        .read(getPromptsProvider)
        .call(GetPromptsParams(afterCursor: afterCursor));
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _isLoadingOlder = false),
      (page) => setState(() {
        // Older pages get prepended so the thread stays oldest-first
        // top-to-bottom even as more history loads in above.
        _history.insertAll(0, page.items);
        _nextCursor = page.nextCursor;
        _isLoadingOlder = false;
      }),
    );
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    _textController.clear();
    final turn = _Turn(text);
    setState(() {
      _isSubmitting = true;
      _turns.add(turn);
    });
    _scrollToBottom();

    final result = await ref.read(createPromptProvider).call(text);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isSubmitting = false;
        turn.error = failure.message;
      }),
      (promptResult) {
        setState(() {
          _isSubmitting = false;
          turn.result = promptResult;
        });
        if (promptResult.triageLevel == TriageLevel.high) {
          ref
              .read(voiceAssistantControllerProvider.notifier)
              .speak(_spokenTextFor(promptResult));
        }
      },
    );
    _scrollToBottom();
  }

  /// What gets read aloud for a HIGH-priority result — the actionable
  /// first-aid guidance itself, not the triage label.
  String _spokenTextFor(PromptResult result) {
    final firstAid = result.firstAid;
    if (firstAid != null && firstAid.steps.isNotEmpty) {
      return 'High priority. ${firstAid.steps.join('. ')}';
    }
    if (result.message != null) return 'High priority. ${result.message}';
    return 'High priority. Please seek medical attention immediately.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // The API already returns items oldest-first, so no reversal is needed
    // — reversing here put the newest message at the top instead of the
    // bottom of the thread.
    final orderedHistory = _history;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Care')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                if (_nextCursor != null && !_isLoadingOlder)
                  Center(
                    child: TextButton(
                      onPressed: () => _loadOlder(afterCursor: _nextCursor),
                      child: const Text('Load older messages'),
                    ),
                  ),
                if (_isLoadingOlder)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                for (final prompt in orderedHistory)
                  ..._buildHistoryTurn(prompt),
                for (final turn in _turns) ..._buildTurn(turn),
              ],
            ),
          ),
          _Composer(
            controller: _textController,
            isSubmitting: _isSubmitting,
            onSend: _submit,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHistoryTurn(Prompt prompt) {
    final widgets = <Widget>[];
    if (prompt.text != null) {
      widgets.add(_UserBubble(text: prompt.text!, createdAt: prompt.createdAt));
    }
    if (prompt.triageLevel != null || prompt.firstAidString != null) {
      widgets.add(_HistoryAiBubble(prompt: prompt));
    }
    return widgets;
  }

  List<Widget> _buildTurn(_Turn turn) {
    final widgets = <Widget>[_UserBubble(text: turn.userText, createdAt: null)];
    final result = turn.result;
    final error = turn.error;
    if (result != null) {
      widgets.add(_ResultAiBubble(result: result));
    } else if (error != null) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(error, style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
        ),
      );
    } else if (_isSubmitting && turn == _turns.last) {
      widgets.add(const _TypingBubble());
    }
    return widgets;
  }
}

/// One submitted message this session and its eventual outcome — either a
/// [result], an [error], or (while `_isSubmitting`) still in flight.
class _Turn {
  _Turn(this.userText);

  final String userText;
  PromptResult? result;
  String? error;
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSubmitting,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    hintText: 'Describe your symptoms...',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Material(
                        color: isSubmitting
                            ? AppColors.outlineVariant
                            : AppColors.electricBlue,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: isSubmitting ? null : onSend,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.send,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text, required this.createdAt});

  final String text;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text(text, style: AppTextStyles.bodyMd),
          ),
          if (createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                _formatTime(createdAt!),
                style: AppTextStyles.labelCaps,
              ),
            ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour24 = time.hour;
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

class _HistoryAiBubble extends StatelessWidget {
  const _HistoryAiBubble({required this.prompt});

  final Prompt prompt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.aiBubbleTint,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prompt.triageLevel != null) ...[
                _TriageChip(level: prompt.triageLevel!),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (prompt.firstAidString != null)
                Text(prompt.firstAidString!, style: AppTextStyles.bodyMd),
              if (prompt.triageLevel == TriageLevel.high) ...[
                const SizedBox(height: AppSpacing.xs),
                const _NearbyHospitalCallButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultAiBubble extends StatelessWidget {
  const _ResultAiBubble({required this.result});

  final PromptResult result;

  @override
  Widget build(BuildContext context) {
    final isHigh = result.triageLevel == TriageLevel.high;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.aiBubbleTint,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: isHigh
                ? Border.all(color: AppColors.triageHigh.withValues(alpha: 0.2))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result.triageLevel != null) ...[
                _TriageChip(level: result.triageLevel!),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (result.message != null) ...[
                Text(result.message!, style: AppTextStyles.bodyMd),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (result.firstAid != null)
                _FirstAidCard(firstAid: result.firstAid!, isHigh: isHigh),
              if (isHigh) ...[
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        dialPhoneNumber(AppConstants.emergencyServiceNumber),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
                    ),
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Emergency Services'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const _NearbyHospitalCallButton(),
              ],
              if (result.hospitalLookupNeeded ?? false) ...[
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pushNamed(RouteNames.hospitalList),
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('Find Nearby Hospitals'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  const _FirstAidCard({required this.firstAid, required this.isHigh});

  final FirstAid firstAid;
  final bool isHigh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isHigh
            ? AppColors.errorContainer
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        border: Border.all(
          color: isHigh
              ? AppColors.triageHigh.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isHigh ? Icons.local_hospital : Icons.medical_services,
                size: 18,
                color: isHigh ? AppColors.triageHigh : AppColors.electricBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  // The backend sometimes sends `firstAid` as a plain
                  // string with no title — fall back to a generic heading.
                  firstAid.title.isNotEmpty
                      ? firstAid.title
                      : (isHigh
                            ? 'Immediate Actions'
                            : 'Recommended First Aid'),
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHigh
                        ? AppColors.onErrorContainer
                        : AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final step in firstAid.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 8),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: isHigh
                          ? AppColors.onErrorContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isHigh
                            ? AppColors.onErrorContainer
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NearbyHospitalCallButton extends ConsumerWidget {
  const _NearbyHospitalCallButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(nearbyHospitalsProvider);

    return hospitalsAsync.maybeWhen(
      data: (hospitals) {
        final nearest = hospitals
            .where((h) => h.phoneNumber != null && h.phoneNumber!.isNotEmpty)
            .firstOrNull;
        if (nearest == null) return const SizedBox.shrink();

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => dialPhoneNumber(nearest.phoneNumber!),
            icon: const Icon(Icons.local_hospital),
            label: Text('Call ${nearest.name}'),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _TriageChip extends StatelessWidget {
  const _TriageChip({required this.level});

  final TriageLevel level;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (level) {
      TriageLevel.high => (
        'Priority: High',
        AppColors.triageHigh,
        Icons.emergency,
      ),
      TriageLevel.medium => (
        'Priority: Medium',
        AppColors.triageMedium,
        Icons.warning,
      ),
      TriageLevel.low => (
        'Priority: Low',
        AppColors.triageLow,
        Icons.info_outline,
      ),
    };
    return PillChip(label: label, color: color, icon: icon);
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 14,
          ),
          decoration: const BoxDecoration(
            color: AppColors.aiBubbleTint,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
