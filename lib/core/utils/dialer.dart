import 'package:url_launcher/url_launcher.dart';

/// Launches the device dialer for [phoneNumber]. Used both from the
/// hospital detail screen and the "call emergency" voice command.
Future<bool> dialPhoneNumber(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri);
}
