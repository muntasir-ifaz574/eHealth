import 'package:dio/dio.dart';
import 'package:ehealth/core/config/env.dart';
import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/error/exceptions.dart';
import 'package:ehealth/features/hospital/data/models/hospital_model.dart';

abstract interface class HospitalRemoteDataSource {
  Future<List<HospitalModel>> fetchNearbyHospitals({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  });

  Future<HospitalModel> fetchHospitalDetails(String placeId);
}

class HospitalRemoteDataSourceImpl implements HospitalRemoteDataSource {
  HospitalRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<HospitalModel>> fetchNearbyHospitals({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.placesNearbySearchUrl,
        queryParameters: {
          'location': '$latitude,$longitude',
          'radius': radiusMeters,
          'type': ApiConstants.hospitalKeyword,
          'key': Env.googlePlacesApiKey,
        },
      );

      final status = response.data?['status'] as String?;
      if (status != null && status != 'OK' && status != 'ZERO_RESULTS') {
        throw ServerException(
          response.data?['error_message'] as String? ?? status,
        );
      }

      final results = (response.data?['results'] as List?) ?? const [];
      return results
          .cast<Map<String, dynamic>>()
          .map(HospitalModel.fromNearbySearchJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load nearby hospitals.');
    }
  }

  @override
  Future<HospitalModel> fetchHospitalDetails(String placeId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.placeDetailsUrl,
        queryParameters: {
          'place_id': placeId,
          'fields':
              'place_id,name,formatted_address,formatted_phone_number,'
              'international_phone_number,geometry,rating',
          'key': Env.googlePlacesApiKey,
        },
      );

      final status = response.data?['status'] as String?;
      if (status != null && status != 'OK') {
        throw ServerException(
          response.data?['error_message'] as String? ?? status,
        );
      }

      final result = response.data?['result'] as Map<String, dynamic>?;
      if (result == null)
        throw const ServerException('Hospital details not found.');

      return HospitalModel.fromDetailsJson(result);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load hospital details.');
    }
  }
}
