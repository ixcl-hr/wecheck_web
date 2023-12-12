// import '../widgets/app_barcode_scanner_widget.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';

///
/// FullScreenScannerPage

class ScanQrCodePage extends StatefulWidget {
  const ScanQrCodePage({super.key});

  //final void Function(String result)? resultCallback;
  @override
  ScanQrCodePageState createState() => ScanQrCodePageState();
}

class ScanQrCodePageState extends State<ScanQrCodePage> {
  String _code = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("「$_code」"),
            ],
          ),
          Expanded(
            child: AiBarcodeScanner(
              onScan: (String value) {
                debugPrint(value);
              },
              onDetect: (BarcodeCapture barcodeCapture) {
                //debugPrint(barcodeCapture);
                String code = barcodeCapture.raw.toString();
                setState(() {
                  if (code.isNotEmpty && code != _code) {
                    _code = code;
                    Navigator.pop(context, code);
                  }
                });
              },
            ),
            // child: AppBarcodeScannerWidget.defaultStyle(
            //   resultCallback: (String code) {
            //     setState(() {
            //       if (code.isNotEmpty && code != _code) {
            //         _code = code;
            //         Navigator.pop(context, code);
            //       }
            //     });
            //   },
            // ),
          ),
        ],
      ),
    );
  }
}
