import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ga_payment/ga_payment.dart';

void main() {
  const MethodChannel channel = MethodChannel('ga_payment');

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
    expect(await GaPayment.platformVersion, '42');
  });
}
