import 'package:epermits/parts/security_drawer.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../parts/hrd_drawer.dart';

class HomeHRD extends StatefulWidget {
  final Function() logoutHandler;

  HomeHRD({required this.logoutHandler});

  @override
  State<HomeHRD> createState() => _HomeHRDState();
}

class _HomeHRDState extends State<HomeHRD> {
  logoutHandler() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Lanjutkan logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Logout');
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Logout');
                await localStorage.remove('token');
                widget.logoutHandler();
              },
              child: Text('Logout'),
            ),
          ],
        );
      }
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Turtle'),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Exit Permits', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      drawer: SecurityDrawer(
        logoutHandler: this.logoutHandler,
      ),
    );
  }
}