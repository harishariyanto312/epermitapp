import 'dart:convert';

import 'package:epermits/pages/check_permit.dart';
import 'package:epermits/pages/home.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../network/sanctum_api.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../parts/security_drawer.dart';

class HomeSecurity extends StatefulWidget {
  final Function() logoutHandler;

  HomeSecurity({required this.logoutHandler});

  @override
  State<HomeSecurity> createState() => _HomeSecurityState();
}

class _HomeSecurityState extends State<HomeSecurity> {
  final inputPermitID = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var isLoading = false;

  logoutHandler() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Lanjutkan logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Batal');
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Logout');
                await localStorage.remove('token');
                widget.logoutHandler();
              },
              child: Text('Logout'),
            ),
          ],
        );
      }
    );
  }

  showSpinner() {
    return Center(
      child: SpinKitDoubleBounce(
        color: AppTheme.theme.colorScheme.primary,
        size: 50,
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isLoading ? null : _generateFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Exit Permits', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
        /*
        actions: <Widget>[
          PopupMenuButton(
            color: AppTheme.customTheme.cardDark,
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.theme.colorScheme.onPrimary,
            ),
            onSelected: (result) {
              if (result == 0) {
                widget.logoutHandler();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.create, size: 18,),
                      FxSpacing.width(8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        */
      ),
      body: isLoading ? showSpinner() : _securityMainScreen(),
      drawer: SecurityDrawer(
        logoutHandler: this.logoutHandler,
      ),
    );
  }

  _securityMainScreen() {
    return Form(
      key: _formKey,
      child: Container(
        padding: FxSpacing.nTop(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 12),
              child: FxText.sh1('Masukkan Nomor Surat Izin Keluar', fontWeight: 600,),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nomor Surat',
                border: AppTheme.theme.inputDecorationTheme.border,
                enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                prefixIcon: Icon(
                  MdiIcons.numeric,
                  size: 24,
                ),
              ),
              controller: inputPermitID,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor tidak boleh kosong';
                }
                return null;
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 8,),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.theme.colorScheme.primary.withAlpha(28),
                      blurRadius: 4,
                      offset: Offset(0 ,3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _checkPermit,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(FxSpacing.xy(16, 0)),
                  ),
                  child: FxText.button(
                    'CEK',
                    fontWeight: 700,
                    color: AppTheme.theme.colorScheme.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _generateFab() {
    return FloatingActionButton.extended(
      onPressed: () async {
        /*
        var result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanner()),
        );
        */
        String result = await FlutterBarcodeScanner.scanBarcode(
          '#FFFFFF',
          'Kembali',
          true,
          ScanMode.QR
        );
        if (!result.isEmpty && result != '-1') {
          setState(() {
            isLoading = true;
          });

          var permitID = result;
          var permitData = await _getPermit(permitID);

          if (permitData['errors'] == null) {
            _permitFound(permitData['result']['permit']);
          }
          else {
            setState(() {
              isLoading = false;
            });
            _showDialog(
              MdiIcons.fileQuestion,
              'Izin Keluar Tidak Ditemukan!',
              'Periksa kembali nomor surat izin keluar',
            );
          }
        }
      },
      elevation: 2,
      label: FxText.sh2(
        ' Scan QR'.toUpperCase(),
        fontWeight: 600,
        color: AppTheme.theme.colorScheme.onPrimary,
        letterSpacing: 0.3,
      ),
      icon: Icon(MdiIcons.qrcodeScan),
    );
  }

  _getPermit(permitID) async {
    var res = await SanctumApi().sendGet(
      apiURL: 'permits/' + permitID.toString(),
      additionalHeaders: {},
      withToken: true,
    );
    var body = jsonDecode(res.body);
    return body;
  }

  _checkPermit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      var permitID = inputPermitID.text;
      var permitData = await _getPermit(permitID);

      if (permitData['errors'] == null) {
        inputPermitID.text = '';
        _permitFound(permitData['result']['permit']);
      }
      else {
        setState(() {
          isLoading = false;
        });
        _showDialog(
          MdiIcons.fileQuestion,
          'Izin Keluar Tidak Ditemukan!',
          'Periksa kembali nomor surat izin keluar',
        );
      }
    }
  }

  _showDialog(icon, dialogTitle, dialogCaption) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.theme.backgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Center(
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppTheme.theme.colorScheme.onBackground.withAlpha(220),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Center(
                    child: FxText.sh1(dialogTitle, fontWeight: 700,),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Center(
                    child: FxText.caption(
                      dialogCaption,
                      fontWeight: 500,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Center(
                    child: FxButton(
                      backgroundColor: AppTheme.theme.colorScheme.background,
                      elevation: 2,
                      borderRadiusAll: 4,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: FxText.caption(
                        'OK',
                        fontWeight: 600,
                        letterSpacing: 0.3,
                        color: AppTheme.theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _permitFound(permitData) async {
    if (permitData['status'] == 'PENDING') {
        setState(() {
          isLoading = false;
        });
        _showDialog(
          MdiIcons.closeOctagon,
          'Izin Belum Mendapat TTD!',
          'Surat izin keluar ini belum mendapat tanda tangan atasan',
        );
        return;
    }
    else if (permitData['status'] == 'READY') {
      var res = await SanctumApi().sendGet(
        apiURL: 'permits/' + permitData['id'].toString() + '/security-check',
        additionalHeaders: {},
        withToken: true,
      );
      setState(() {
        isLoading = false;
      });
      var body = jsonDecode(res.body);
      print(body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckPermit(
          permitData: permitData,
        )),
      );
      return;
    }
    setState(() {
      isLoading = false;
    });
    return;
  }
}