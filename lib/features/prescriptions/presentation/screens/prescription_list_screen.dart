import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/utils/file_opener.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';
import 'package:ehealth/features/prescriptions/domain/usecases/verify_prescription.dart';
import 'package:ehealth/features/prescriptions/presentation/providers/prescriptions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime? date) {
  if (date == null) return 'Unknown date';
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

class PrescriptionListScreen extends ConsumerWidget {
  const PrescriptionListScreen({super.key, required this.consultationId});

  final String consultationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(prescriptionsForConsultationProvider(consultationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: AsyncValueWidget(
        value: prescriptionsAsync,
        onRetry: () => ref.invalidate(prescriptionsForConsultationProvider(consultationId)),
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return Center(
              child: Text('No prescriptions for this consultation yet.', style: AppTextStyles.bodyMd),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            children: [
              Text('Active Prescriptions', style: AppTextStyles.headlineMd),
              const SizedBox(height: AppSpacing.sm),
              for (final prescription in prescriptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PrescriptionRow(prescription: prescription),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PrescriptionRow extends ConsumerStatefulWidget {
  const _PrescriptionRow({required this.prescription});

  final Prescription prescription;

  @override
  ConsumerState<_PrescriptionRow> createState() => _PrescriptionRowState();
}

class _PrescriptionRowState extends ConsumerState<_PrescriptionRow> {
  bool _isOpening = false;
  bool _isVerifying = false;
  PrescriptionVerification? _verifyResult;
  String? _errorMessage;

  /// Resolves the prescription's own stored file — from the local cache if
  /// it's already been downloaded, otherwise downloading it first.
  Future<String?> _resolveLocalFile() async {
    final result = await ref.read(getLocalPrescriptionFileProvider).call(widget.prescription);
    return result.fold((failure) {
      setState(() => _errorMessage = failure.message);
      return null;
    }, (path) => path);
  }

  Future<void> _viewPdf() async {
    setState(() {
      _isOpening = true;
      _errorMessage = null;
    });

    final path = await _resolveLocalFile();
    if (!mounted) return;
    if (path != null) {
      final openError = await openLocalFile(path);
      if (!mounted) return;
      if (openError != null) setState(() => _errorMessage = openError);
    }
    setState(() => _isOpening = false);
  }

  Future<void> _verify() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _verifyResult = null;
    });

    final path = await _resolveLocalFile();
    if (!mounted) return;
    if (path == null) {
      setState(() => _isVerifying = false);
      return;
    }

    final result = await ref.read(verifyPrescriptionProvider).call(
          VerifyPrescriptionParams(
            prescriptionId: widget.prescription.prescriptionId.toString(),
            filePath: path,
          ),
        );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isVerifying = false;
        _errorMessage = failure.message;
      }),
      (verification) => setState(() {
        _isVerifying = false;
        _verifyResult = verification;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescription = widget.prescription;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.medication, color: AppColors.electricBlue),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, size: 18, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs / 2),
                        Expanded(
                          child: Text(
                            prescription.fileName,
                            style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text('Issued: ${_formatDate(prescription.createdAt)}', style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_isOpening || _isVerifying) ? null : _viewPdf,
                  icon: _isOpening
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('View'),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: FilledButton(
                  onPressed: (_isOpening || _isVerifying) ? null : _verify,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_errorMessage!, style: AppTextStyles.bodySm.copyWith(color: AppColors.triageHigh)),
          ],
          if (_verifyResult != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _VerificationResultCard(result: _verifyResult!),
          ],
        ],
      ),
    );
  }
}

class _VerificationResultCard extends StatelessWidget {
  const _VerificationResultCard({required this.result});

  final PrescriptionVerification result;

  @override
  Widget build(BuildContext context) {
    final matched = result.isDbMatch && result.isBlockchainMatch;
    final color = matched ? AppColors.triageLow : AppColors.triageHigh;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(matched ? Icons.check_circle : Icons.cancel, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                matched ? 'Verified Match' : 'Not Verified',
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
          if (!matched) ...[
            const SizedBox(height: AppSpacing.xs / 2),
            Text('Mismatch Detected', style: AppTextStyles.labelCaps.copyWith(color: color)),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text('File hash: ${result.fileHash}', style: AppTextStyles.labelCaps),
          Text('Stored hash: ${result.storedHash}', style: AppTextStyles.labelCaps),
          if (result.blockchainTxHash != null)
            Text('Tx: ${result.blockchainTxHash}', style: AppTextStyles.labelCaps),
        ],
      ),
    );
  }
}
