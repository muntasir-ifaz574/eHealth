import 'package:open_filex/open_filex.dart';

Future<String?> openLocalFile(String path) async {
  final result = await OpenFilex.open(path);
  if (result.type == ResultType.done) return null;
  return result.message.isNotEmpty
      ? result.message
      : 'Unable to open this file.';
}
