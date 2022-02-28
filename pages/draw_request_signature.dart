import 'dart:convert';

import 'package:epermits/network/sanctum_api.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class DrawRequestSignature extends StatefulWidget {
  var permitID;

  DrawRequestSignature({required this.permitID});

  @override
  State<DrawRequestSignature> createState() => _DrawRequestSignatureState();
}

class _DrawRequestSignatureState extends State<DrawRequestSignature> {
  var userNIK, userName, userID;
  bool _isSaveButtonDisabled = false;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  _getUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      userID = localStorage.getString('userID');
      userName = localStorage.getString('userName');
      userNIK = localStorage.getString('userNIK');
    });
  }

  @override
  void initState() {
    super.initState();
    this._getUserData();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Permintaan TTD', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: ListView(
        padding: FxSpacing.nTop(20),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16),
          ),
          infoDetail('Nama', userName),
          infoDetail('NIK', userNIK),
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Signature(
              controller: _signatureController,
              width: 300,
              height: 200,
              backgroundColor: Color.fromARGB(255, 255, 205, 210),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: IconButton(
                  icon: Icon(Icons.undo),
                  color: AppTheme.theme.colorScheme.primary,
                  onPressed: () {
                    setState(() {
                      _signatureController.undo();
                    });
                  },
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.redo),
                  color: AppTheme.theme.colorScheme.primary,
                  onPressed: () {
                    setState(() {
                      _signatureController.redo();
                    });
                  },
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.delete),
                  color: AppTheme.theme.colorScheme.primary,
                  onPressed: () {
                    setState(() {
                      _signatureController.clear();
                    });
                  },
                ),
              ),
            ],
          ),

          Container(
            margin: EdgeInsets.only(top: 16),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.theme.colorScheme.primary.withAlpha(28),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (!_isSaveButtonDisabled) {
                    if (_signatureController.isNotEmpty) {
                      var userSignature = await _signatureController.toPngBytes();
                      bool isSaved = await _saveSignature(userSignature);
                      if (isSaved) {
                        Navigator.pop(context);
                      }
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: FxText.sh1(
                            'Tanda tangan harus diisi',
                            color: AppTheme.theme.colorScheme.onPrimary,
                          ),
                          backgroundColor: AppTheme.theme.colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                    }
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(FxSpacing.xy(16, 0)),
                ),
              child: FxText.button(
                _isSaveButtonDisabled ? 'MEMPROSES...' : 'SIMPAN',
                fontWeight: 700,
                color: AppTheme.theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  infoTitle(str) {
    return Container(
      padding: FxSpacing.symmetric(vertical: 4,),
      child: FxText.sh1(str, fontWeight: 700, letterSpacing: 0,),
    );
  }

  infoDetail(title, value) {
    return Container(
      padding: FxSpacing.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FxText.sh2(title, fontWeight: 600,),
          FxText.b1(value),
        ],
      ),
    );
  }

  _saveSignature(userSignature) async {
    setState(() {
      _isSaveButtonDisabled = true;
    });

    var dataSignature = {
      'superior_id': userID,
      'user_signature': base64Encode(userSignature),
    };

    var res = await SanctumApi().sendPost(
      data: dataSignature,
      apiURL: 'permits/' + widget.permitID.toString() + '/same-device-signature',
      additionalHeaders: {},
      withToken: true,
    );
    var body = jsonDecode(res.body);

    setState(() {
      _isSaveButtonDisabled = false;
    });

    if (body['errors'] == null) {
      return true;
    }
    else {
      return false;
    }
  }
}