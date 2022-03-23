import 'package:epermits/pages/check_permit.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../parts/permit_panel.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../network/sanctum_api.dart';

getPermit(permitID) async {
  var res = await SanctumApi().sendGet(
    apiURL: 'permits/' + permitID.toString(),
    additionalHeaders: {},
    withToken: true
  );
  var body = jsonDecode(res.body);
  return body;
}

class AcceptPermit extends StatefulWidget {
  var permitID;

  AcceptPermit({required this.permitID});

  @override
  State<AcceptPermit> createState() => _AcceptPermitState();
}

class _AcceptPermitState extends State<AcceptPermit> {
  var permitData;
  var isLoading = true;

  getPermitData() async {
    var tempPermitData = await getPermit(widget.permitID);
    setState(() {
      permitData = tempPermitData;
      if (permitData != null) {
        isLoading = false;
      }
    });
  }

  @override 
  void initState() {
    super.initState();
    getPermitData();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Meminta Persetujuan', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: isLoading ? showSpinner() : PermitPanel(
        permitData: permitData['result']['permit'],
      ),
      floatingActionButton: _giveSignature(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  _giveSignature() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pop(context);
      }, 
      elevation: 2,
      label: FxText.sh2(
        ' Selesai'.toUpperCase(),
        fontWeight: 600,
        color: AppTheme.theme.colorScheme.onPrimary,
        letterSpacing: 0.3,
      ),
      icon: Icon(MdiIcons.draw),
    );
  }
}