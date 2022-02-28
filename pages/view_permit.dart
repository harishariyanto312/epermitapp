import 'dart:convert';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../network/sanctum_api.dart';
import './draw_signature.dart';
import 'package:url_launcher/url_launcher.dart';
import './add_person.dart';
import '../parts/permit_panel.dart';
import './show_qr.dart';

getPermit(permitID) async {
  var res = await SanctumApi().sendGet(
    apiURL: 'permits/' + permitID.toString(),
    additionalHeaders: {},
    withToken: true
  );
  var body = jsonDecode(res.body);
  return body;
}

class ViewPermit extends StatefulWidget {
  var permitID;

  ViewPermit({required this.permitID});

  @override
  State<ViewPermit> createState() => _ViewPermitState();
}

class _ViewPermitState extends State<ViewPermit> {
  var permitData;
  var isLoading = true;
  var currentStatus;
  var isShared;
  var additionalUsers;

  getPermitData() async {
    var tempPermitData = await getPermit(widget.permitID);
    setState(() {
      permitData = tempPermitData;
      currentStatus = permitData['result']['permit']['status'];
      isShared = permitData['result']['permit']['is_shared'];
      additionalUsers = permitData['result']['permit']['additional_users'];
      print(isShared);

      if (permitData != null) {
        isLoading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPermitData();
  }

  void _showBottomSheet(context) {
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext buildContext) {
        return Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.theme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16)
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FxText.sh1('Menu', fontWeight: 700,),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  _QuickActionWidget(
                                    iconData: MdiIcons.refresh, 
                                    actionText: 'Refresh',
                                    actionClicked: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        isLoading = true;
                                      });
                                      getPermitData();
                                    },
                                  ),
                                  currentStatus == 'PENDING' && isShared == false
                                  ? _QuickActionWidget(
                                      iconData: MdiIcons.accountPlus, 
                                      actionText: 'Tambah Orang', 
                                      actionClicked: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AddPerson(
                                            permitID: widget.permitID,
                                          )),
                                        ).then((_) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          getPermitData();
                                        });
                                      },
                                    )
                                  : Container(),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  currentStatus == 'PENDING' && isShared == false
                                  ? _QuickActionWidget(
                                    iconData: MdiIcons.draw, 
                                    actionText: 'Tanda tangani',
                                    actionClicked: () async {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DrawSignature(
                                          permitID: permitData['result']['permit']['id'],
                                        )),
                                      ).then((_) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        getPermitData();
                                      });
                                    },
                                  )
                                  : Container(),
                                  _QuickActionWidget(
                                    iconData: MdiIcons.filePdfBox, 
                                    actionText: 'Simpan PDF', 
                                    actionClicked: () async {
                                      var pdfURL = permitData['result']['permit']['pdf_url'];
                                      if (!await launch(pdfURL)) throw 'Could not launch $pdfURL';
                                    }
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  currentStatus == 'PENDING' && isShared == false
                                  ? _QuickActionWidget(
                                    iconData: MdiIcons.send, 
                                    actionText: 'Kirim',
                                    actionClicked: () {
                                      print('Kirim');
                                    },
                                  )
                                  : Container(),

                                  _QuickActionWidget(
                                    iconData: MdiIcons.qrcode,
                                    actionText: 'Kode QR',
                                    actionClicked: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowQR(
                                          permitID: permitData['result']['permit']['id'],
                                        )),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context);
        },
        child: Icon(
          MdiIcons.dotsGrid,
          size: 26,
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
        elevation: 2,
        backgroundColor: AppTheme.theme.floatingActionButtonTheme.backgroundColor,
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Izin Keluar', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: isLoading ? showSpinner() : PermitPanel(
        permitData: permitData['result']['permit'],
      ),
    );
  }

  showSpinner() {
    return Center(
      child: SpinKitDoubleBounce(
        color: AppTheme.theme.colorScheme.primary,
        size: 50,
      ),
    );
  }

  infoTitle(str) {
    return Container(
      padding: FxSpacing.symmetric(vertical: 4,),
      child: FxText.sh1(str, fontWeight: 700, letterSpacing: 0,),
    );
  }

  infoDetail(title, value) {
    return Container(
      padding: FxSpacing.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FxText.sh2(title, fontWeight: 600,),
          FxText.b1(value),
        ],
      ),
    );
  }
}

class _QuickActionWidget extends StatelessWidget {
  final IconData iconData;
  final String actionText;
  Function actionClicked;

  _QuickActionWidget({
    Key? key,
    required this.iconData,
    required this.actionText,
    required this.actionClicked
  }) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(top: 12, bottom: 12),
      child: Column(
        children: <Widget>[
          ClipOval(
            child: Material(
              color: AppTheme.theme.colorScheme.primary.withAlpha(20),
              child: InkWell(
                splashColor: AppTheme.theme.colorScheme.primary.withAlpha(20),
                highlightColor: Colors.transparent,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(
                    iconData,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: () {
                  actionClicked();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: FxText.caption(
              actionText,
              fontWeight: 600,
            ),
          ),
        ],
      ),
    );
  }
}