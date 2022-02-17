import 'dart:io';

import 'package:epermits/pages/view_permit.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/login.dart';
import './pages/home.dart';
import './pages/view_permit.dart';

class AppHttpOverrides extends HttpOverrides {
  @override 
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = AppHttpOverrides();
  runApp(StartApp());
}

class StartApp extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePermits Sejati',
      theme: AppTheme.theme,
      home: CheckAuthentication(),
      routes: {
        '/view-permit': (context) => ViewPermit()
      }
    );
  }
}

class CheckAuthentication extends StatefulWidget {
  @override
  State<CheckAuthentication> createState() => _CheckAuthenticationState();
}

class _CheckAuthenticationState extends State<CheckAuthentication> {
  bool isAuthenticated = false;

  @override 
  void initState() {
    super.initState();
    _checkIfAuthenticated();
  }

  void _checkIfAuthenticated() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      if (mounted) {
        setState(() {
          isAuthenticated = true;
        });
      }
    }
  }

  void loginHandler() {
    setState(() {
      isAuthenticated = true;
    });
  }

  void logoutHandler() {
    setState(() {
      isAuthenticated = false;
    });  
  }

  @override 
  Widget build(BuildContext context) {
    Widget child;

    if (isAuthenticated) {
      child = Home(logoutHandler: logoutHandler);
    }
    else {
      child = Login(loginHandler: loginHandler);
    }

    return child;
  }
}