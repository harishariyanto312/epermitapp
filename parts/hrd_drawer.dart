import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './single_drawer_item.dart';

class HRDDrawer extends StatefulWidget {
  final Function() logoutHandler;

  HRDDrawer({required this.logoutHandler});

  @override
  State<HRDDrawer> createState() => _HRDDrawerState();
}

class _HRDDrawerState extends State<HRDDrawer> {
  String? userName = '';
  var _selectedPageCode = 'home';

  getUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      userName = localStorage.getString('userName');
    });
  }

  @override 
  void initState() {
    super.initState();
    this.getUserData();
  }

  @override 
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.theme.backgroundColor,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: DrawerHeader(
                padding: FxSpacing.all(0),
                margin: FxSpacing.all(0),
                child: Container(
                  height: double.infinity,
                  child: Padding(
                    padding: FxSpacing.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FxText.h6(
                              userName!, fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,
                            ),
                            Padding(padding: EdgeInsets.only(top: 4)),
                            FxText.b2(
                              'HRD',fontWeight: 500, color: AppTheme.theme.colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                decoration: BoxDecoration(color: AppTheme.theme.colorScheme.background),
              ),
            ),

            Expanded(
              flex: 6,
              child: Container(
                color: AppTheme.theme.backgroundColor,
                child: Padding(
                  padding: FxSpacing.bottom(8),
                  child: ListView(
                    padding: FxSpacing.all(0),
                    children: <Widget>[
                      SingleDrawerItem(
                        selectedPageCode: _selectedPageCode, 
                        iconData: Icons.logout, 
                        title: 'Logout', 
                        pageCode: 'logout', 
                        action: () {
                          Navigator.pop(context);
                          widget.logoutHandler();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}