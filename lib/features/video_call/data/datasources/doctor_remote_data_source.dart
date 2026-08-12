import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_endpoints.dart';
import 'package:ehealth/features/video_call/data/models/conference_credentials_model.dart';
import 'package:ehealth/features/video_call/data/models/doctor_model.dart';

abstract interface class DoctorRemoteDataSource {
  Future<List<DoctorModel>> fetchAvailableDoctors();

  Future<ConferenceCredentialsModel> fetchConferenceCredentials(String consultationId);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  DoctorRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DoctorModel>> fetchAvailableDoctors() async {
    final response = await _dio.get<List<dynamic>>(ApiEndpoints.doctors);
    return (response.data ?? []).cast<Map<String, dynamic>>().map(DoctorModel.fromJson).toList();
  }

  @override
  Future<ConferenceCredentialsModel> fetchConferenceCredentials(String consultationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.consultationConference(consultationId),
    );
    return ConferenceCredentialsModel.fromJson(response.data!);
  }
}
