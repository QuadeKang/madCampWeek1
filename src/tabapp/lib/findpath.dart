
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> get findPath async {
  final directory = await getApplicationDocumentsDirectory();
  final businessCardDir = Directory(path.join(directory.path, 'business_card'));

  if (!await businessCardDir.exists()) {
    await businessCardDir.create(recursive: true);
  }

  return businessCardDir.path;
}