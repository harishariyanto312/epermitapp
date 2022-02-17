import 'dart:convert';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:epermits/network/sanctum_api.dart';
import './home.dart';

class Login extends StatefulWidget {
  final Function() loginHandler;
  Login({required this.loginHandler});
  
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordVisible = false;
  bool _isLoading = false;
  String _helpUrl = 'https://mssupport.co.id';
  var userNik, userPassword, userDevice;
  var fieldNikErrorText = null;
  var fieldPasswordErrorText = null;
  final _formKey = GlobalKey<FormState>();

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: _LoginCustomClipper(context),
            child: Container(
              alignment: Alignment.center,
              color: AppTheme.theme.colorScheme.background,
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            top: MediaQuery.of(context).size.height * 0.2,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                FxContainer.bordered(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  color: AppTheme.theme.scaffoldBackgroundColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 24, top: 8),
                        child: FxText.h6('LOGIN', fontWeight: 600,),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                style: FxTextStyle.b1(
                                  letterSpacing: 0.1,
                                  color: AppTheme.theme.colorScheme.onBackground,
                                  fontWeight: 500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'NIK',
                                  hintStyle: FxTextStyle.sh2(
                                    letterSpacing: 0.1,
                                    color: AppTheme.theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                  ),
                                  prefixIcon: Icon(MdiIcons.numeric),
                                  errorText: fieldNikErrorText,
                                ),
                                validator: (nikValue) {
                                  if (nikValue != null && nikValue.isEmpty) {
                                    return 'NIK tidak boleh kosong';
                                  }
                                  userNik = nikValue;
                                  return null;
                                },
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 16),
                                child: TextFormField(
                                  style: FxTextStyle.b1(
                                    letterSpacing: 0.1,
                                    color: AppTheme.theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: FxTextStyle.sh2(
                                      letterSpacing: 0.1,
                                      color: AppTheme.theme.colorScheme.onBackground,
                                      fontWeight: 500,
                                    ),
                                    prefixIcon: Icon(MdiIcons.lockOutline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                        ? MdiIcons.eyeOutline
                                        : MdiIcons.eyeOffOutline
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    errorText: fieldPasswordErrorText,
                                  ),
                                  obscureText: !_passwordVisible,
                                  validator: (passwordValue) {
                                    if (passwordValue != null && passwordValue.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    userPassword = passwordValue;
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 16),
                                child: FxButton.block(
                                  disabled: _isLoading,
                                  backgroundColor: AppTheme.theme.colorScheme.background,
                                  elevation: 0,
                                  borderRadiusAll: 4,
                                  padding: FxSpacing.y(12),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                                  child: FxText.button(
                                    _isLoading ? 'Memproses ...' : 'LOGIN',
                                    fontWeight: 600,
                                    color: AppTheme.theme.colorScheme.onPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (!await launch(_helpUrl)) throw 'Could not launch $_helpUrl';
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        'Bantuan',
                        style: FxTextStyle.b2(
                          fontWeight: 600,
                          color: AppTheme.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    userDevice = androidInfo.model;
    if (userDevice.isEmpty) {
      userDevice = 'Unknown';
    }

    var res = await SanctumApi().authenticate(
      userNik: userNik,
      userPassword: userPassword,
      userDevice: userDevice
    );
    var body = jsonDecode(res.body);

    print(body);

    setState(() {
      if (body['errors'] != null && body['errors']['nik'] != null && body['errors']['nik'][0] != null) {
        fieldNikErrorText = body['errors']['nik'][0];
      }
      else {
        fieldNikErrorText = null;
      }

      if (body['errors'] != null && body['errors']['password'] != null && body['errors']['password'][0] != null) {
        fieldPasswordErrorText = body['errors']['password'][0];
      }
      else {
        fieldPasswordErrorText = null;
      }
    });

    if (body['errors'] == null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', body['result']['token']);
      localStorage.setString('userID', (body['result']['user']['id']).toString());
      localStorage.setString('userName', body['result']['user']['name']);
      localStorage.setString('userNIK', body['result']['user']['nik']);

      /*
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (BuildContext context) => Home()
        )
      );
      */
      widget.loginHandler();
    }

    setState(() {
      _isLoading = false;
    });
  }
}

class _LoginCustomClipper extends CustomClipper<Path> {
  final BuildContext _context;

  _LoginCustomClipper(this._context);

  @override 
  Path getClip(Size size) {
    final path = Path();
    Size size = MediaQuery.of(_context).size;
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(0, size.height * 0.6);
    path.close();
    return path;
  }

  @override 
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}