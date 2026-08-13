import 'package:url_launcher/url_launcher.dart';

Future<bool> dialPhoneNumber(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri);
}
