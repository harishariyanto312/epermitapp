import 'package:epermits/pages/home.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './scanner.dart';

class HomeSecurity extends StatefulWidget {
  final Function() logoutHandler;

  HomeSecurity({required this.logoutHandler});

  @override
  State<HomeSecurity> createState() => _HomeSecurityState();
}

class _HomeSecurityState extends State<HomeSecurity> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _generateFab(),
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
    );
  }

  _generateFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanner()),
        );
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
}