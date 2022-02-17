import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ViewPermit extends StatefulWidget {
  @override
  State<ViewPermit> createState() => _ViewPermitState();
}

class _ViewPermitState extends State<ViewPermit> {
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
        child: SpinKitDoubleBounce(
          color: AppTheme.theme.colorScheme.primary,
          size: 50,
        ),
      ),
    );
  }
}