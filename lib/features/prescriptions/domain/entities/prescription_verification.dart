import 'package:equatable/equatable.dart';

class PrescriptionVerification extends Equatable {
  const PrescriptionVerification({
    required this.isDbMatch,
    required this.isBlockchainMatch,
    required this.fileHash,
    required this.storedHash,
    this.blockchainTxHash,
    this.blockchainId,
  });

  final bool isDbMatch;
  final bool isBlockchainMatch;
  final String fileHash;
  final String storedHash;
  final String? blockchainTxHash;
  final int? blockchainId;

  @override
  List<Object?> get props =>
      [isDbMatch, isBlockchainMatch, fileHash, storedHash, blockchainTxHash, blockchainId];
}
