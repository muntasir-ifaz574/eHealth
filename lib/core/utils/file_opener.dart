import 'package:open_filex/open_filex.dart';

/// Opens a local file with whatever app the OS associates with its type.
/// Returns an error message on failure, or null on success.
Future<String?> openLocalFile(String path) async {
  final result = await OpenFilex.open(path);
  if (result.type == ResultType.done) return null;
  return result.message.isNotEmpty ? result.message : 'Unable to open this file.';
}
