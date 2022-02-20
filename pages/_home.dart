import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './login.dart';
import './create_permit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Home extends StatefulWidget {
  final Function() logoutHandler;
  Home({required this.logoutHandler});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  logoutHandler() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userName = localStorage.getString('userName');
    var userNIK = localStorage.getString('userNIK');
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Anda login menggunakan akun dengan nama ${userName} (NIK : ${userNIK}). Lanjutkan logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Batal');
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

  createHandler() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CreatePermit()
      )
    );
  }

  bool _isLoading = true;

  loadingScreen() {
    return Center(
      child: SpinKitDoubleBounce(
        color: AppTheme.theme.colorScheme.primary,
        size: 50,
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? loadingScreen() : Center(
        child: Text('Colossus'),
      ),
      backgroundColor: AppTheme.customTheme.cardDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('ePermits Sejati', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        actions: <Widget>[
          PopupMenuButton(
            color: AppTheme.customTheme.cardDark,
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.theme.colorScheme.onPrimary,
            ),
            onSelected: (result) {
              if (result == 0) {
                createHandler();
              }
              else if (result == 1) {
                logoutHandler();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  // onTap: () => createHandler(context),
                  value: 0,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.create, size: 18,),
                      FxSpacing.width(8),
                      Text('Buat Izin'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  // onTap: logoutHandler,
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.logout, size: 18,),
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
}