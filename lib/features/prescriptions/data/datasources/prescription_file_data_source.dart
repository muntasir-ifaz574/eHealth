import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ehealth/core/error/exceptions.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:path_provider/path_provider.dart';

/// Caches a prescription's file on disk (in app-private storage, so no
/// storage permission is needed) and resolves the direct-download form of
/// `fileRef` when it's a Google Drive share link, since Drive's "view" URL
/// serves an HTML viewer page rather than the raw file over a plain GET.
abstract interface class PrescriptionFileDataSource {
  Future<String?> findCachedFile(Prescription prescription);

  Future<String> downloadFile(Prescription prescription);
}

class PrescriptionFileDataSourceImpl implements PrescriptionFileDataSource {
  PrescriptionFileDataSourceImpl(this._dio);

  final Dio _dio;

  static final _driveViewPattern = RegExp(r'drive\.google\.com/file/d/([^/]+)');

  Future<String> _localPathFor(Prescription prescription) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeName = prescription.fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return '${dir.path}/prescriptions/${prescription.prescriptionId}_$safeName';
  }

  @override
  Future<String?> findCachedFile(Prescription prescription) async {
    final path = await _localPathFor(prescription);
    return File(path).existsSync() ? path : null;
  }

  @override
  Future<String> downloadFile(Prescription prescription) async {
    final path = await _localPathFor(prescription);
    final file = File(path);
    await file.parent.create(recursive: true);

    final response = await _dio.get<List<int>>(
      _directDownloadUrl(prescription.fileRef),
      options: Options(responseType: ResponseType.bytes),
    );

    final contentType = response.headers.value('content-type') ?? '';
    if (contentType.startsWith('text/html')) {
      throw const ServerException(
        "Couldn't download this file directly — the source link needs to be opened in a browser instead.",
      );
    }

    await file.writeAsBytes(response.data!);
    return path;
  }

  String _directDownloadUrl(String fileRef) {
    final match = _driveViewPattern.firstMatch(fileRef);
    if (match == null) return fileRef;
    return 'https://drive.google.com/uc?export=download&id=${match.group(1)}';
  }
}
