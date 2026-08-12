import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';
import 'package:ehealth/features/prescriptions/domain/usecases/verify_prescription.dart';
import 'package:ehealth/features/prescriptions/presentation/providers/prescriptions_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';

class PrescriptionListScreen extends ConsumerStatefulWidget {
  const PrescriptionListScreen({super.key, required this.consultationId});

  final String consultationId;

  @override
  ConsumerState<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends ConsumerState<PrescriptionListScreen> {
  final _verifyPanelKey = GlobalKey();
  String? _selectedPrescriptionId;
  bool _isVerifying = false;
  String? _pickedFilePath;
  String? _pickedFileName;
  PrescriptionVerification? _result;
  String? _errorMessage;

  void _selectForVerification(String prescriptionId) {
    setState(() {
      _selectedPrescriptionId = prescriptionId;
      _pickedFilePath = null;
      _pickedFileName = null;
      _result = null;
      _errorMessage = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panelContext = _verifyPanelKey.currentContext;
      if (panelContext != null) {
        Scrollable.ensureVisible(panelContext, duration: const Duration(milliseconds: 300));
      }
    });
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles();
    final path = picked?.files.single.path;
    if (path == null) return;

    setState(() {
      _pickedFilePath = path;
      _pickedFileName = picked!.files.single.name;
      _result = null;
      _errorMessage = null;
    });
  }

  void _removePickedFile() {
    setState(() {
      _pickedFilePath = null;
      _pickedFileName = null;
    });
  }

  Future<void> _verify() async {
    final prescriptionId = _selectedPrescriptionId;
    final path = _pickedFilePath;
    if (prescriptionId == null || path == null) return;

    setState(() {
      _isVerifying = true;
      _result = null;
      _errorMessage = null;
    });

    final result = await ref.read(verifyPrescriptionProvider).call(
          VerifyPrescriptionParams(prescriptionId: prescriptionId, filePath: path),
        );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isVerifying = false;
        _errorMessage = failure.message;
      }),
      (verification) => setState(() {
        _isVerifying = false;
        _result = verification;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionsAsync = ref.watch(prescriptionsForConsultationProvider(widget.consultationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: AsyncValueWidget(
        value: prescriptionsAsync,
        onRetry: () => ref.invalidate(prescriptionsForConsultationProvider(widget.consultationId)),
        data: (prescriptions) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            children: [
              Text('Active Prescriptions', style: AppTextStyles.headlineMd),
              const SizedBox(height: AppSpacing.sm),
              if (prescriptions.isEmpty)
                Text('No prescriptions for this consultation yet.', style: AppTextStyles.bodyMd)
              else
                ...prescriptions.map(
                  (prescription) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PrescriptionRow(
                      prescription: prescription,
                      onVerify: () => _selectForVerification(prescription.prescriptionId.toString()),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              _VerifyPanel(
                key: _verifyPanelKey,
                isSelected: _selectedPrescriptionId != null,
                pickedFileName: _pickedFileName,
                isVerifying: _isVerifying,
                result: _result,
                errorMessage: _errorMessage,
                onPickFile: _pickFile,
                onRemoveFile: _removePickedFile,
                onVerify: _pickedFileName != null && !_isVerifying ? _verify : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrescriptionRow extends StatelessWidget {
  const _PrescriptionRow({required this.prescription, required this.onVerify});

  final Prescription prescription;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
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
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(onPressed: onVerify, child: const Text('Verify')),
        ],
      ),
    );
  }
}

class _VerifyPanel extends StatelessWidget {
  const _VerifyPanel({
    super.key,
    required this.isSelected,
    required this.pickedFileName,
    required this.isVerifying,
    required this.result,
    required this.errorMessage,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onVerify,
  });

  final bool isSelected;
  final String? pickedFileName;
  final bool isVerifying;
  final PrescriptionVerification? result;
  final String? errorMessage;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.electricBlue),
              const SizedBox(width: AppSpacing.xs),
              Text('Verify Prescription', style: AppTextStyles.headlineMd),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Upload a prescription document to cryptographically verify its authenticity against the eHealth blockchain.',
            style: AppTextStyles.bodySm,
          ),
          if (!isSelected) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Tap "Verify" on a prescription above to get started.', style: AppTextStyles.bodySm),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: isVerifying ? null : onPickFile,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.cloud_upload, color: AppColors.electricBlue),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Click to upload file', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                    Text('PDF, JPG, PNG', style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            ),
            if (pickedFileName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        pickedFileName!,
                        style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: isVerifying ? null : onRemoveFile,
                      icon: const Icon(Icons.close, color: AppColors.triageHigh),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onVerify,
                child: isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify Authenticity'),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(errorMessage!, style: AppTextStyles.bodySm.copyWith(color: AppColors.triageHigh)),
            ],
            if (result != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _VerificationResultCard(result: result!),
            ],
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

    return AppCard(
      color: color.withValues(alpha: .08),
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
