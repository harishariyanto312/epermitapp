import 'dart:convert';

import 'package:epermits/pages/home.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './scanner.dart';
import '../network/sanctum_api.dart';

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
      ),
      body: isLoading ? showSpinner() : _securityMainScreen(),
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
        var result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanner()),
        );
        if (result != null) {
          setState(() {
            isLoading = true;
          });

          var permitID = result;
          var permitData = await _getPermit(permitID);

          setState(() {
            isLoading = false;
          });

          if (permitData['errors'] == null) {
            print('OK Found');
          }
          else {
            _showDialog();
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

      setState(() {
        isLoading = false;
      });

      if (permitData['errors'] == null) {
        print('OK Found');
      }
      else {
        _showDialog();
      }
    }
  }

  _showDialog() {
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
                      MdiIcons.fileQuestion,
                      size: 40,
                      color: AppTheme.theme.colorScheme.onBackground.withAlpha(220),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Center(
                    child: FxText.sh1('Izin Keluar Tidak Ditemukan!', fontWeight: 700,),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Center(
                    child: FxText.caption(
                      'Periksa kembali nomor surat izin keluar',
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
}