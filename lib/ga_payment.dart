import 'dart:async';

import 'package:flutter/services.dart';

class GaPayment {
  static const MethodChannel _channel = const MethodChannel('ga_payment');

  static Future<Map<String, dynamic?>> get getParameters async {
    final parameters = await _channel
        .invokeMethod('getParameters')
        .then((value) => Map<String, dynamic?>.from(value));
    return parameters;
  }

  static Future<Map<String, dynamic?>> transaction(
      double amount, String transType, bool print) async {
    final paymentResult = await _channel.invokeMapMethod('transaction', {
      "amount": amount,
      "transType": "$transType",
      "print": print
    }).then((value) => Map<String, dynamic?>.from(value!));
    return paymentResult;
  }

  static Future<Map<String, dynamic?>> checkPendingRequest() async {
    final pendingResult = await _channel.invokeMethod('checkPendingRequest').then((value) => Map<String, dynamic?>.from(value!));
    return pendingResult;
  }
}
