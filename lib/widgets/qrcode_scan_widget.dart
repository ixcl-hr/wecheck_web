import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// late String _label;
// late Function(String result) _resultCallback;
bool isPush = false;
Barcode? result;
QRViewController? controller;

class QrCodeScannerWidget extends StatefulWidget {
  ///
  ///
  QrCodeScannerWidget.defaultStyle({
    Key? key,
    Function(String result)? resultCallback,
    String label = '',
  }) : super(key: key) {
    // _resultCallback = resultCallback ?? (String result) {};
    // _label = label;
    isPush = true;
  }

  @override
  _QrCodeScannerState createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScannerWidget> {
  //final GlobalKey<keywidg> _fbKey = GlobalKey<FormBuilderState>();
  final key = GlobalKey();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: key,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Center(
          //     child: (result != null)
          //         ? Text(
          //             'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
          //         : const Text('Scan a code'),
          //   ),
          // )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controllerprm) {
    controller = controllerprm;
    controller!.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null && result!.code != null && isPush) {
          isPush = false;
          //_resultCallback(result!.code!);
          Navigator.pop(context, result!.code!);
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
