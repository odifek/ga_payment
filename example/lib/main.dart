import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ga_payment/ga_payment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic?> _terminalParamsResult = {"data": "", "statusMessage": ""};

  @override
  void initState() {
    super.initState();
    checkPendingRequests();
  }

  Future<void> checkPendingRequests() async {
    Map<String, dynamic?>? pendingResult;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      pendingResult = await GaPayment.checkPendingRequest();
    } on PlatformException {
      pendingResult = null;
    } on MissingPluginException {
      pendingResult = null;
    }
    print("Check pending Results: $pendingResult");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    if (pendingResult == null) return;

    setState(() {
      if (pendingResult != null)
      _terminalParamsResult = pendingResult;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getTerminalParameters() async {
    Map<String, dynamic?> terminalParamsResult;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      terminalParamsResult = await GaPayment.getParameters;
    } on PlatformException {
      terminalParamsResult = {"data": "Failed to get terminal parameters"};
    } on MissingPluginException {
      terminalParamsResult = {"data": "get parameters not implemented"};
    }
    print(terminalParamsResult);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _terminalParamsResult = terminalParamsResult;
    });
  }

  Future<void> requestPayment(double amount) async {
    Map<String, dynamic?> paymentResult;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      paymentResult = await GaPayment.transaction(amount, "PURCHASE", false);
    } on PlatformException {
      paymentResult = {"data": "Failed to complete payment"};
    } on MissingPluginException {
      paymentResult = {"data": "transaction plugin not implemented"};
    }
    print(paymentResult);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _terminalParamsResult = paymentResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              child: TextButton(
                onPressed: _requestTerminalParameters,
                child: Text("Get Terminal Parameters"),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              child: TextButton(
                onPressed: _requestPayment,
                child: Text("N1.0 Purchase"),
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: Text(
                    "Status: ${_terminalParamsResult["statusMessage"]}\nResponse:\n${_terminalParamsResult["data"]}"))
          ],
        ),
      ),
    );
  }

  void _requestTerminalParameters() {
    print("Parameter request should be started");
    getTerminalParameters();
  }

  void _requestPayment() {
    requestPayment(1.0);
  }
}
