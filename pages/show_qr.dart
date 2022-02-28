import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQR extends StatefulWidget {
  var permitID;

  ShowQR({required this.permitID});

  @override
  State<ShowQR> createState() => _ShowQRState();
}

class _ShowQRState extends State<ShowQR> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Izin Keluar : #' + widget.permitID.toString(), fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImage(
              data: widget.permitID.toString(),
              version: QrVersions.auto,
              size: MediaQuery.of(context).size.width * 0.7,
              embeddedImage: AssetImage('assets/images/logo-white.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(50, 50),
              ),
              // backgroundColor: Color.fromARGB(255, 251, 209, 13),
              foregroundColor: Color.fromARGB(255, 230, 33, 42),
            ),
            /*
            Container(
              margin: EdgeInsets.only(top: 24),
              child: FxText.h3(
                'Nomor : #' + widget.permitID.toString(),
                color: AppTheme.theme.colorScheme.onBackground,
                fontWeight: 600,
                letterSpacing: 0,
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}