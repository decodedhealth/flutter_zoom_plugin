import 'dart:core';
import 'dart:io';
import 'package:archive/archive.dart';

void main(List<String> args) {

  var location = Platform.script.toString().replaceFirst("file://", "").replaceFirst("/bin/unzip_zoom_sdk.dart", "");

  var filename = location + '/ios-sdk/MobileRTC${(args.length == 0) ? "" : "-dev"}.zip';

  print('Decompressing ' + filename);

  final bytes = File(filename).readAsBytesSync();

  final archive = ZipDecoder().decodeBytes(bytes);

  var current = new File(location + '/ios/MobileRTC.framework/MobileRTC');
  current.deleteSync();

  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File(location + '/ios/MobileRTC.framework/' + filename)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }

  print('Complete');
}
