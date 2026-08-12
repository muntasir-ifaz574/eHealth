import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';
import 'package:ehealth/features/prescriptions/domain/usecases/verify_prescription.dart';
import 'package:ehealth/features/prescriptions/presentation/providers/prescriptions_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrescriptionVerifyScreen extends ConsumerStatefulWidget {
  const PrescriptionVerifyScreen({super.key, required this.prescriptionId});

  final String prescriptionId;

  @override
  ConsumerState<PrescriptionVerifyScreen> createState() => _PrescriptionVerifyScreenState();
}

class _PrescriptionVerifyScreenState extends ConsumerState<PrescriptionVerifyScreen> {
  bool _isVerifying = false;
  String? _pickedFileName;
  PrescriptionVerification? _result;
  String? _errorMessage;

  Future<void> _pickAndVerify() async {
    final picked = await FilePicker.platform.pickFiles();
    final path = picked?.files.single.path;
    if (path == null) return;

    setState(() {
      _isVerifying = true;
      _pickedFileName = picked!.files.single.name;
      _result = null;
      _errorMessage = null;
    });

    final result = await ref.read(verifyPrescriptionProvider).call(
          VerifyPrescriptionParams(prescriptionId: widget.prescriptionId, filePath: path),
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
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: _isVerifying ? null : _pickAndVerify,
              icon: const Icon(Icons.upload_file),
              label: Text(_pickedFileName ?? 'Choose file to verify'),
            ),
            if (_isVerifying) const Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(),
            ),
            if (_errorMessage != null) Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
            if (result != null) Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _VerificationRow(label: 'Database match', matched: result.isDbMatch),
                      _VerificationRow(label: 'Blockchain match', matched: result.isBlockchainMatch),
                      const SizedBox(height: 12),
                      Text('File hash: ${result.fileHash}', style: const TextStyle(fontSize: 12)),
                      Text('Stored hash: ${result.storedHash}', style: const TextStyle(fontSize: 12)),
                      if (result.blockchainTxHash != null)
                        Text('Tx: ${result.blockchainTxHash}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({required this.label, required this.matched});

  final String label;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(matched ? Icons.check_circle : Icons.cancel, color: matched ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
