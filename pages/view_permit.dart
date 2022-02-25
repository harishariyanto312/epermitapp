import 'dart:convert';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../network/sanctum_api.dart';
import 'package:badges/badges.dart';
import './draw_signature.dart';
import 'package:url_launcher/url_launcher.dart';

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

  getPermitData() async {
    var tempPermitData = await getPermit(widget.permitID);
    setState(() {
      permitData = tempPermitData;
      currentStatus = permitData['result']['permit']['status'];
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
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  currentStatus == 'PENDING'
                                  ? _QuickActionWidget(
                                    iconData: MdiIcons.draw, 
                                    actionText: 'Tanda tangani',
                                    actionClicked: () async {
                                      var permitID = permitData['result']['permit']['id'];
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
                                  currentStatus == 'PENDING'
                                  ? _QuickActionWidget(
                                    iconData: MdiIcons.send, 
                                    actionText: 'Kirim',
                                    actionClicked: () {
                                      print('Kirim');
                                    },
                                  )
                                  : Container(),
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
      body: isLoading ? showSpinner() : permitDetails(),
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

  List<bool> _dataExpansionPanel = [true, true, true, true];

  permitDetails() {
    return ListView(
      children: <Widget>[
        Container(
          padding: FxSpacing.xy(24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FxText.sh2('Status', fontWeight: 600,),
                  statusBadge(permitData['result']['permit']['status']),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FxText.sh2('Nomor', fontWeight: 600,),
                  FxText.b1('#' + (permitData['result']['permit']['id']).toString()),
                ],
              ),
            ],
          ),
        ),
        Container(
          color: AppTheme.theme.backgroundColor,
          padding: FxSpacing.all(16),
          child: Column(
            children: <Widget>[
              ExpansionPanelList(
                expandedHeaderPadding: EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _dataExpansionPanel[index] = !isExpanded;
                  });
                },
                animationDuration: Duration(milliseconds: 500),
                children: <ExpansionPanel>[

                  // Identitas Karyawan
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        padding: FxSpacing.all(16),
                        child: FxText.sh1(
                          'Identitas Karyawan',
                          fontWeight: isExpanded ? 700 : 600,
                          letterSpacing: 0,
                        ),
                      );
                    },
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: FxSpacing.fromLTRB(24, 0, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FxText.sh1(
                            'Nama',
                            fontWeight: 600,
                            height: 1.4,
                          ),
                          FxText.sh2(
                            permitData['result']['permit']['user']['name'],
                            height: 1.4,
                            fontWeight: 500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          FxText.sh1(
                            'NIK',
                            fontWeight: 600,
                            height: 1.4,
                          ),
                          FxText.sh2(
                            permitData['result']['permit']['user']['nik'],
                            height: 1.4,
                            fontWeight: 500,
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _dataExpansionPanel[0],
                  ),

                  // Detail
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        padding: FxSpacing.all(16),
                        child: FxText.sh1(
                          'Detail Izin',
                          fontWeight: isExpanded ? 700 : 600,
                          letterSpacing: 0,
                        ),
                      );
                    },
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: FxSpacing.fromLTRB(24, 0, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FxText.sh1(
                            'Hari',
                            fontWeight: 600,
                            height: 1.4,
                          ),
                          FxText.sh2(
                            permitData['result']['permit']['day'],
                            height: 1.4,
                            fontWeight: 500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          FxText.sh1(
                            'Tanggal',
                            fontWeight: 600,
                            height: 1.4,
                          ),
                          FxText.sh2(
                            permitData['result']['permit']['date'],
                            height: 1.4,
                            fontWeight: 500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          FxText.sh1(
                            'Jam',
                            fontWeight: 600,
                            height: 1.4,
                          ),
                          FxText.sh2(
                            permitData['result']['permit']['time'],
                            height: 1.4,
                            fontWeight: 500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          FxText.sh1(
                            'Alasan',
                            fontWeight: 600,
                            height: 1.4,
                          ),
                          FxText.sh2(
                            permitData['result']['permit']['permit_excuse'],
                            height: 1.4,
                            fontWeight: 500,
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _dataExpansionPanel[1],
                  ),

                  // Tanda Tangan Karyawan
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        padding: FxSpacing.all(16),
                        child: FxText.sh1(
                          'Tanda Tangan Karyawan',
                          fontWeight: isExpanded ? 700 : 600,
                          letterSpacing: 0,
                        ),
                      );
                    },
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: FxSpacing.fromLTRB(24, 0, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: FxSpacing.only(top: 16, bottom: 8,),
                            child: Center(
                              child: Image.network(permitData['result']['permit']['user_signature'], width: MediaQuery.of(context).size.width / 2,)
                            ),
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _dataExpansionPanel[2],
                  ),

                  ..._superiorSignature(),

                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<ExpansionPanel> _superiorSignature() {
    if (currentStatus == 'READY') {
      return <ExpansionPanel>[
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
              padding: FxSpacing.all(16),
              child: FxText.sh1(
                'Tanda Tangan Atasan',
                fontWeight: isExpanded ? 700 : 600,
                letterSpacing: 0,
              ),
            );
          },
          body: Container(
            width: MediaQuery.of(context).size.width,
            padding: FxSpacing.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FxText.sh1(
                  'Nama',
                  fontWeight: 600,
                  height: 1.4,
                ),
                FxText.sh2(
                  permitData['result']['permit']['superior']['name'],
                  height: 1.4,
                  fontWeight: 500,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                ),
                FxText.sh1(
                  'NIK',
                  fontWeight: 600,
                  height: 1.4,
                ),
                FxText.sh2(
                  permitData['result']['permit']['superior']['nik'],
                  height: 1.4,
                  fontWeight: 500,
                ),
                Container(
                  padding: FxSpacing.only(top: 16, bottom: 8,),
                  child: Center(
                    child: Image.network(permitData['result']['permit']['superior_signature'], width: MediaQuery.of(context).size.width / 2,)
                  ),
                ),
              ],
            ),
          ),
          isExpanded: _dataExpansionPanel[3],
        ),
      ];
    }
    else {
      return <ExpansionPanel>[];
    }
  }

  statusBadge(status) {
    var child;
    switch (status) {
      case 'PENDING':
        child = Badge(
          toAnimate: false,
          shape: BadgeShape.square,
          badgeColor: Colors.yellow,
          borderRadius: BorderRadius.circular(8),
          badgeContent: Text('Menunggu TTD Atasan', style: TextStyle(color: Colors.black),),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        );
        break;
      case 'READY':
        child = Badge(
          toAnimate: false,
          shape: BadgeShape.square,
          badgeColor: Colors.green,
          borderRadius: BorderRadius.circular(8),
          badgeContent: Text('Data Lengkap', style: TextStyle(color: Colors.white),),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        );
        break;
      default:
        child = Badge(
          toAnimate: false,
          shape: BadgeShape.square,
          badgeColor: Colors.red,
          borderRadius: BorderRadius.circular(8),
          badgeContent: Text('ERROR', style: TextStyle(color: Colors.white),),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        );
        break;
    }
    return child;
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