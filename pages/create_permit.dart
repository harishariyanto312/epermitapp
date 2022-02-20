import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:signature/signature.dart';
import '../parts/create_permit_stepper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './view_permit.dart';

class CreatePermit extends StatefulWidget {
  @override
  State<CreatePermit> createState() => _CreatePermitState();
}

class _CreatePermitState extends State<CreatePermit> {
  var token, userID, userName, userNIK;
  bool _isCurrentlyLoading = false;
  bool _isPermitCreated = false;
  int permitCreatedID = 0;

  @override
  void initState() {
    super.initState();
    this.getUserData();
  }

  getUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      token = localStorage.getString('token');
      userID = localStorage.getString('userID');
      userName = localStorage.getString('userName');
      userNIK = localStorage.getString('userNIK');
    });
  }

  void toggleLoadingStatus() {
    setState(() {
      _isCurrentlyLoading = !_isCurrentlyLoading;
    });
  }

  void permitCreated(permitID) {
    setState(() {
      _isPermitCreated = true;
    });
    permitCreatedID = permitID;
  }

  @override 
  Widget build(BuildContext context) {
    Widget child;
    if (_isCurrentlyLoading) {
      child = Scaffold(
        body: Center(
          child: SpinKitDoubleBounce(
            color: AppTheme.theme.colorScheme.primary,
            size: 50,
          ),
        ),
      );
    }
    else {
      if (!_isPermitCreated) {
        child = CreatePermitStepper(
          token: token,
          userID: userID,
          userName: userName,
          userNIK: userNIK,
          toggleLoadingStatus: toggleLoadingStatus,
          permitCreated: permitCreated
        );
      }
      else {
        child = ViewPermit(
          permitID: permitCreatedID,
        );
      }
    }
    return child;
  }
}