import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zoom_plugin/zoom_view.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_zoom_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
//
//  test('getPlatformVersion', () async {
//    expect(await ZoomView.platformVersion, '42');
//  });
}
