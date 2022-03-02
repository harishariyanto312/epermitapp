import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import './home_security.dart';

class Scanner extends StatefulWidget {
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool isFlashlightOn = false;

  @override 
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
      ? 150.0
      : 300.0;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width / 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ClipOval(
                    child: Material(
                      color: AppTheme.theme.colorScheme.background,
                      child: InkWell(
                        splashColor: Colors.white,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.flip_camera_android, color: Colors.white,),
                        ),
                        onTap: () async {
                          await controller?.flipCamera();
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  ClipOval(
                    child: Material(
                      color: AppTheme.theme.colorScheme.background,
                      child: InkWell(
                        splashColor: Colors.white,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(isFlashlightOn ? Icons.flashlight_off : Icons.flashlight_on, color: Colors.white,),
                        ),
                        onTap: () async {
                          await controller?.toggleFlash();
                          setState(() {
                            isFlashlightOn = !isFlashlightOn;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Scan QR', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool scanned = false;
    controller.scannedDataStream.listen((scanData) {
      if (!scanned) {
        scanned = true;
        setState(() {
          result = scanData;
        });
        controller.pauseCamera();
        Navigator.pop(context, result?.code);
      }
    });
  }
}