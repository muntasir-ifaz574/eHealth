import 'package:permission_handler/permission_handler.dart';

/// Central place to request the runtime permissions the app relies on:
/// location (nearby hospitals), microphone (voice commands + calls) and
/// camera (video calls).
class PermissionService {
  const PermissionService();

  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestCallEssentials() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    return statuses.values.every((status) => status.isGranted);
  }
}
