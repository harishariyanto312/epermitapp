import 'dart:io';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/login.dart';
import './pages/home.dart';
import './pages/home_security.dart';
import './pages/home_hrd.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
    );
  }
}

bool _initialUriIsHandled = false;

class CheckAuthentication extends StatefulWidget {
  @override
  State<CheckAuthentication> createState() => _CheckAuthenticationState();
}

class _CheckAuthenticationState extends State<CheckAuthentication> {
  bool isAuthenticated = false;
  bool? isUserSecurity = false;
  bool? isUserHrd = false;

  Uri? _initialUri;
  Uri? _latestUri;
  Uri? _unifiedUri;
  Object? _err;
  StreamSubscription? _sub;

  @override 
  void initState() {
    super.initState();
    _checkIfAuthenticated();
    _checkIfUserSecurity();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  @override 
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _err = null;
        if (_latestUri != null) {
          _unifiedUri = _latestUri;
        }
      });
    }, onError: (Object err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        if (err is FormatException) {
          _err = err;
        }
        else {
          _err = null;
        }
      });
    });
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (!mounted) return;
        setState(() {
          _initialUri = uri;
          if (_initialUri != null) {
            _unifiedUri = _initialUri;
          }
        });
      } on PlatformException {
        print('Failed to get initial URI');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('Malformed initial URI');
        setState(() {
          _err = err;
        });
      }
    }
  }

  void _checkIfUserSecurity() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      isUserSecurity = localStorage.getBool('isSecurity');
    });
  }

  void _checkIfUserHrd() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      isUserHrd = localStorage.getBool('isHrd');
    });
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
    _checkIfUserSecurity();
    _checkIfUserHrd();
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
      if (isUserSecurity!) {
        child = HomeSecurity(
          logoutHandler: logoutHandler
        );
      }
      else if (isUserHrd!) {
        child = HomeHRD(
          logoutHandler: logoutHandler
        );
      }
      else {
        var queryParamsFormatted = {};
        var queryParams = _unifiedUri?.queryParametersAll.entries.toList();
        if (queryParams != null) {
          for (final item in queryParams) {
            queryParamsFormatted[item.key] = item.value.join('');
          }
        }
        print(queryParamsFormatted);
        child = Home(
          logoutHandler: logoutHandler,
          deepLinkData: queryParamsFormatted,
        );
      }
    }
    else {
      child = Login(loginHandler: loginHandler);
    }

    _unifiedUri = null;
    _initialUri = null;
    _latestUri = null;
    return child;
  }
}