import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:badges/badges.dart';

class PermitPanel extends StatefulWidget {
  var permitData;

  PermitPanel({required this.permitData});

  @override
  State<PermitPanel> createState() => _PermitPanelState();
}

class _PermitPanelState extends State<PermitPanel> {
  List<bool> _dataExpansionPanel = [true, true, true, true];

  List<Widget> _additionalUsersNames() {
    var names = <Widget>[];
    for (var item in widget.permitData['additional_users']) {
      names.add(
        FxText.sh2(item['name'], height: 1.4, fontWeight: 500,),
      );
    }
    return names;
  }

  List<Widget> _additionalUsersNiks() {
    var niks = <Widget>[];
    for (var item in widget.permitData['additional_users']) {
      niks.add(
        FxText.sh2(item['nik'], height: 1.4, fontWeight: 500,)
      );
    }
    return niks;
  }

  @override 
  Widget build(BuildContext context) {
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
                  statusBadge(widget.permitData['status']),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FxText.sh2('Nomor', fontWeight: 600,),
                  FxText.b1('#' + (widget.permitData['id'].toString())),
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
                        padding: EdgeInsets.all(16),
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
                          FxText.sh1('Nama', fontWeight: 600, height: 1.4,),
                          FxText.sh2(widget.permitData['user']['name'], height: 1.4, fontWeight: 500,),
                          ..._additionalUsersNames(),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          FxText.sh1('NIK', fontWeight: 600, height: 1.4,),
                          FxText.sh2(widget.permitData['user']['nik'], height: 1.4, fontWeight: 500,),
                          ..._additionalUsersNiks(),
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
                          FxText.sh1('Hari', fontWeight: 600, height: 1.4,),
                          FxText.sh2(widget.permitData['day'], height: 1.4, fontWeight: 500,),
                          Padding(
                            padding: EdgeInsets.only(top: 8)
                          ),
                          FxText.sh1('Tanggal', fontWeight: 600, height: 1.4,),
                          FxText.sh2(widget.permitData['date'], height: 1.4, fontWeight: 500,),
                          Padding(
                            padding: EdgeInsets.only(top: 8)
                          ),
                          FxText.sh1('Jam', fontWeight: 600, height: 1.4,),
                          FxText.sh2(widget.permitData['time'], height: 1.4, fontWeight: 500,),
                          Padding(
                            padding: EdgeInsets.only(top: 8)
                          ),
                          FxText.sh1('Alasan', fontWeight: 600, height: 1.4,),
                          FxText.sh2(widget.permitData['permit_excuse'], height: 1.4, fontWeight: 500,),
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
                              child: Image.network(widget.permitData['user_signature'], width: MediaQuery.of(context).size.width / 2,),
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
    if (widget.permitData['status'] == 'READY') {
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
                FxText.sh1('Nama', fontWeight: 600, height: 1.4,),
                FxText.sh2(widget.permitData['superior']['name'], height: 1.4, fontWeight: 500,),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                ),
                FxText.sh1('NIK', fontWeight: 600, height: 1.4,),
                FxText.sh2(widget.permitData['superior']['nik'], height: 1.4, fontWeight: 500,),
                Container(
                  padding: FxSpacing.only(top: 16, bottom: 8,),
                  child: Center(
                    child: Image.network(widget.permitData['superior_signature'], width: MediaQuery.of(context).size.width / 2,),
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
}