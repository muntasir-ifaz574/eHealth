import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';
import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';
import 'package:ehealth/features/prompts/domain/usecases/get_prompts.dart';
import 'package:ehealth/features/prompts/presentation/providers/prompts_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;
  PromptResult? _result;
  String? _errorMessage;

  final List<Prompt> _history = [];
  String? _nextCursor;
  bool _historyLoaded = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory({String? afterCursor}) async {
    setState(() => _isLoadingMore = true);
    final result = await ref.read(getPromptsProvider).call(GetPromptsParams(afterCursor: afterCursor));
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _isLoadingMore = false),
      (page) => setState(() {
        _history.addAll(page.items);
        _nextCursor = page.nextCursor;
        _historyLoaded = true;
        _isLoadingMore = false;
      }),
    );
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _result = null;
    });

    final result = await ref.read(createPromptProvider).call(text);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
      (promptResult) => setState(() {
        _isSubmitting = false;
        _result = promptResult;
        _textController.clear();
        _history.clear();
        _nextCursor = null;
        _historyLoaded = false;
      }),
    );
    if (_history.isEmpty && !_historyLoaded) await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Describe your symptoms',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Check Symptoms'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          if (result != null) ...[
            const SizedBox(height: 20),
            _PromptResultCard(result: result),
          ],
          const SizedBox(height: 24),
          const Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._history.map((prompt) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(prompt.text ?? '(no text)'),
                  subtitle: prompt.triageLevel != null ? Text(prompt.triageLevel!.name.toUpperCase()) : null,
                ),
              )),
          if (_isLoadingMore) const Center(child: CircularProgressIndicator()),
          if (_nextCursor != null && !_isLoadingMore)
            TextButton(
              onPressed: () => _loadHistory(afterCursor: _nextCursor),
              child: const Text('Load more'),
            ),
        ],
      ),
    );
  }
}

class _PromptResultCard extends StatelessWidget {
  const _PromptResultCard({required this.result});

  final PromptResult result;

  Color get _triageColor {
    switch (result.triageLevel) {
      case TriageLevel.high:
        return Colors.red;
      case TriageLevel.medium:
        return Colors.orange;
      case TriageLevel.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(result.triageLevel.name.toUpperCase()),
              backgroundColor: _triageColor.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: _triageColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(result.firstAid.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...result.firstAid.steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $step'),
                )),
            if (result.hospitalLookupNeeded) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.hospitalList),
                icon: const Icon(Icons.local_hospital),
                label: const Text('Find Nearby Hospitals'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
