import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:epos2_printer/epos2_printer.dart';

void main() {
  const MethodChannel channel = MethodChannel('epos2_printer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Epos2Printer.platformVersion, '42');
  });
}
