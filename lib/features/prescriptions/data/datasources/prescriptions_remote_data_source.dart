import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_endpoints.dart';
import 'package:ehealth/features/prescriptions/data/models/prescription_model.dart';
import 'package:ehealth/features/prescriptions/data/models/prescription_verification_model.dart';

abstract interface class PrescriptionsRemoteDataSource {
  Future<List<PrescriptionModel>> fetchPrescriptions(String consultationId);

  Future<PrescriptionVerificationModel> verifyPrescription({
    required String prescriptionId,
    required String filePath,
  });
}

class PrescriptionsRemoteDataSourceImpl implements PrescriptionsRemoteDataSource {
  PrescriptionsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<PrescriptionModel>> fetchPrescriptions(String consultationId) async {
    final response = await _dio.get<List<dynamic>>(
      ApiEndpoints.consultationPrescriptions(consultationId),
    );
    return (response.data ?? []).cast<Map<String, dynamic>>().map(PrescriptionModel.fromJson).toList();
  }

  @override
  Future<PrescriptionVerificationModel> verifyPrescription({
    required String prescriptionId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPrescription(prescriptionId),
      data: formData,
    );
    return PrescriptionVerificationModel.fromJson(response.data!);
  }
}
