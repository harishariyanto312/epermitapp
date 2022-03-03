import 'package:epermits/pages/create_permit.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/create_permit.dart';
import './single_drawer_item.dart';

class RegularUserDrawer extends StatefulWidget {
  final Function() pageRefresher;
  final Function() logoutHandler;

  RegularUserDrawer({required this.pageRefresher, required this.logoutHandler});

  @override
  State<RegularUserDrawer> createState() => _RegularUserDrawerState();
}

class _RegularUserDrawerState extends State<RegularUserDrawer> {
  String? userName = '';
  String? userNIK = '';
  var _selectedPageCode = 'home';

  getUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      userName = localStorage.getString('userName');
      userNIK = localStorage.getString('userNIK');
    });
  }

  @override
  void initState() {
    super.initState();
    this.getUserData();
  }

  @override 
  Widget build(BuildContext) {
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
                              'NIK ' + userNIK!, fontWeight: 500, color: AppTheme.theme.colorScheme.onPrimary,
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
                        iconData: Icons.create, 
                        title: 'Buat Izin Keluar',
                        pageCode: 'create', 
                        action: _createHandler,
                      ),
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

  _createHandler() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CreatePermit()
      ),
    ).then((_) {
      Navigator.pop(context);
      widget.pageRefresher();
    });
  }
}