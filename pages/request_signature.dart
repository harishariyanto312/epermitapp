import 'dart:convert';

import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../network/sanctum_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../parts/permit_panel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import './draw_request_signature.dart';

getPermit(permitID) async {
  var res = await SanctumApi().sendGet(
    apiURL: 'permits/encrypted/' + permitID.toString(),
    additionalHeaders: {},
    withToken: true,
  );
  var body = jsonDecode(res.body);
  return body;
}

class RequestSignature extends StatefulWidget {
  final Function() cancelRequestSignature;
  var permitID;

  RequestSignature({required this.cancelRequestSignature, required this.permitID});

  @override
  State<RequestSignature> createState() => _RequestSignatureState();
}

class _RequestSignatureState extends State<RequestSignature> {
  var permitData;
  var currentUserID;
  bool signatureEligible = false;
  var isLoading = true;

  _getPermitData() async {
    var tempPermitData = await getPermit(widget.permitID);
    setState(() {
      permitData = tempPermitData;
    });
    await _signatureEligible();
    setState(() {
      isLoading = false;
    });
  }

  _getCurrentUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    currentUserID = localStorage.getString('userID');
  }

  _signatureEligible() async {
    var res = await SanctumApi().sendGet(
      apiURL: 'permits/' + permitData['result']['permit']['id'].toString() + '/check-give-signature?user_id=' + currentUserID.toString(),
      additionalHeaders: {},
      withToken: true
    );
    var data = jsonDecode(res.body);
    if (data['errors'] == null) {
      setState(() {
        signatureEligible = true;
      });
    }
    else {
      setState(() {
        signatureEligible = false;
      });
    }
    print(data);
  }

  @override 
  void initState() {
    super.initState();
    _getCurrentUserData();
    _getPermitData();
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
    var body;

    if (isLoading) {
      body = showSpinner();
    }
    else {
      if (signatureEligible) {
        if (permitData != null) {
          if (permitData['result']['permit']['status'] == 'PENDING') {
            body = PermitPanel(
              permitData: permitData['result']['permit'],
            );
          }
          else {
            body = alreadySigned();
          }
        }
        else {
          body = showSpinner();
        }
      }
      else {
        body = Center(
          child: Text('Tidak dapat memberi TTD'),
        );
      }
    }

    return Scaffold(
      floatingActionButton: _generateFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Permintaan TTD', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
        /*
        leading: Builder(
          builder: (BuildContext context) {
            return BackButton(
              onPressed: widget.cancelRequestSignature,
            );
          },
        ),
        */
      ),
      body: body,
    );
  }

  _generateFAB() {
    if (permitData != null) {
      if (!isLoading && signatureEligible && permitData['result']['permit']['status'] == 'PENDING') {
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return DrawRequestSignature(
                    permitID: permitData['result']['permit']['id'],
                  );
                },
              ),
            ).then((_) {
              setState(() {
                isLoading = true;
              });
              _getPermitData();
            });
          },
          elevation: 2,
          label: FxText.sh2(
            ' Tanda Tangani'.toUpperCase(),
            fontWeight: 600,
            color: AppTheme.theme.colorScheme.onPrimary,
            letterSpacing: 0.3,
          ),
          icon: Icon(MdiIcons.draw),
        );
      }
      else {
        return;
      }
    }
  }

  alreadySigned() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('./assets/images/done.png'),
              height: MediaQuery.of(context).size.width * 0.6,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 24),
            child: FxText.sh1(
              'Izin sudah ditanda tangani',
              color: AppTheme.theme.colorScheme.onBackground,
              fontWeight: 600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}