import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../parts/permit_panel.dart';

class CheckPermit extends StatefulWidget {
  var permitData;

  CheckPermit({required this.permitData});

  @override
  State<CheckPermit> createState() => _CheckPermitState();
}

class _CheckPermitState extends State<CheckPermit> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Terima', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: PermitPanel(
        permitData: widget.permitData,
      ),
      floatingActionButton: _doneFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _doneFab() {
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
      icon: Icon(MdiIcons.accountCheck),
    );
  }
}