import 'dart:convert';

import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

class ViewPermit extends StatefulWidget {
  var token;
  var permitID;

  ViewPermit({required this.token, required this.permitID});

  @override
  State<ViewPermit> createState() => _ViewPermitState();
}

class _ViewPermitState extends State<ViewPermit> {
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
        title: FxText.sh1('Izin Keluar', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: Center(
        child: isLoading ? showSpinner() : Text(permitData['result']['permit']['status']),
      ),
    );
  }

  showSpinner() {
    return SpinKitDoubleBounce(
      color: AppTheme.theme.colorScheme.primary,
      size: 50,
    );
  }
}