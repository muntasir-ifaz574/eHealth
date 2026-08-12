import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/api_error_mapper.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/prescriptions/data/datasources/prescriptions_remote_data_source.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';
import 'package:ehealth/features/prescriptions/domain/repositories/prescriptions_repository.dart';

class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  const PrescriptionsRepositoryImpl(this._remoteDataSource);

  final PrescriptionsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Prescription>>> getPrescriptions(String consultationId) async {
    try {
      return Right(await _remoteDataSource.fetchPrescriptions(consultationId));
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<PrescriptionVerification>> verifyPrescription({
    required String prescriptionId,
    required String filePath,
  }) async {
    try {
      final verification = await _remoteDataSource.verifyPrescription(
        prescriptionId: prescriptionId,
        filePath: filePath,
      );
      return Right(verification);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
