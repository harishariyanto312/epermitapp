import 'dart:convert';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../network/sanctum_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DrawSignature extends StatefulWidget {
  var permitID;

  DrawSignature({required this.permitID});

  @override
  State<DrawSignature> createState() => _DrawSignatureState();
}

class _DrawSignatureState extends State<DrawSignature> {
  bool isSuperiorFound = false;

  final _formKey = GlobalKey<FormState>();
  var userNik, userName, userID, currentNik;
  var fieldNikErrorText = null;
  bool _selectFromSuggestion = false;

  bool isBtnDisabled = false;

  _getCurrentNik() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    currentNik = localStorage.getString('userNIK');
  }

  @override
  initState() {
    super.initState();
    _getCurrentNik();
  }

  final TextEditingController _fieldSuperiorController = TextEditingController();

  _findSuperior() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: FxSpacing.nTop(20),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 12),
            child: FxText.sh1('Masukkan NIK atau nama atasan', fontWeight: 600,),
          ),
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                labelText: "NIK Atasan",
                border: AppTheme.theme.inputDecorationTheme.border,
                enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                prefixIcon: Icon(
                  MdiIcons.numeric,
                  size: 24,
                ),
                errorText: fieldNikErrorText,
              ),
              controller: this._fieldSuperiorController,
            ),
            suggestionsCallback: (pattern) async {
              var res = await SanctumApi().sendGet(
                apiURL: 'users?q=' + pattern,
                additionalHeaders: {},
                withToken: true,
              );
              var data = jsonDecode(res.body);
              if (data['errors'] == null) {
                return data['result'];
              }
              else {
                return [];
              }
            },
            itemBuilder: (context, suggestion) {
              final itemData = suggestion as Map;
              return ListTile(
                title: Text(itemData['name']),
                subtitle: Text(suggestion['nik']),
              );
            },
            transitionBuilder: (context, suggestionBox, controller) {
              return suggestionBox;
            },
            onSuggestionSelected: (suggestion) {
              final selectedData = suggestion as Map;
              _selectFromSuggestion = true;
              userNik = suggestion['nik'];
              this._fieldSuperiorController.text = selectedData['name'] + ' (' + selectedData['nik'] + ')';
            },
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIK tidak boleh kosong';
                }
                if (_selectFromSuggestion == false) {
                  userNik = value;
                }
                if (userNik == currentNik) {
                  return 'NIK tidak valid';
                }
                return null;
            },
            onSaved: (value) {
            },
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              color: Colors.white,
            ),
            noItemsFoundBuilder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(
                  'NIK/Nama tidak ditemukan',
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          Container(
            margin: EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.theme.colorScheme.primary.withAlpha(28),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (!isBtnDisabled) {
                    if (_formKey.currentState!.validate()) {
                      _findUser();
                    }
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(FxSpacing.xy(16, 0)),
                ),
                child: FxText.button(
                  isBtnDisabled ? 'MEMPROSES ...' : 'BERIKUTNYA',
                  fontWeight: 700,
                  color: AppTheme.theme.colorScheme.onPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isSaveButtonDisabled = false;

  _drawSignature() {
    return ListView(
      padding: FxSpacing.nTop(20),
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 16),
        ),
        infoTitle('Data Atasan'),
        infoDetail('Nama', userName),
        infoDetail('NIK', userNik),
        Container(
          margin: EdgeInsets.only(top: 16),
          child: Signature(
            controller: _signatureController,
            width: 300,
            height: 200,
            backgroundColor: Color.fromARGB(255, 255, 205, 210),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: IconButton(
                icon: Icon(Icons.undo),
                color: AppTheme.theme.colorScheme.primary,
                onPressed: () {
                  setState(() {
                    _signatureController.undo();
                  });
                },
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.redo),
                color: AppTheme.theme.colorScheme.primary,
                onPressed: () {
                  setState(() {
                    _signatureController.redo();
                  });
                },
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.delete),
                color: AppTheme.theme.colorScheme.primary,
                onPressed: () {
                  setState(() {
                    _signatureController.clear();
                  });
                },
              ),
            ),
          ],
        ),

        Container(
          margin: EdgeInsets.only(top: 16),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.theme.colorScheme.primary.withAlpha(28),
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (!_isSaveButtonDisabled) {
                  if (_signatureController.isNotEmpty) {
                    var userSignature = await _signatureController.toPngBytes();
                    bool isSaved = await _saveSignature(userSignature);
                    if (isSaved) {
                      Navigator.pop(context);
                    }
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: FxText.sh1(
                          'Tanda tangan harus diisi',
                          color: AppTheme.theme.colorScheme.onPrimary,
                        ),
                        backgroundColor: AppTheme.theme.colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  }
                }
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(FxSpacing.xy(16, 0)),
              ),
              child: FxText.button(
                _isSaveButtonDisabled ? 'MENYIMPAN ...' : 'SIMPAN',
                fontWeight: 700,
                color: AppTheme.theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

      ],
    );
  }

  _saveSignature(userSignature) async {
    setState(() {
      _isSaveButtonDisabled = true;
    });

    var dataSignature = {
      'superior_id': userID,
      'user_signature': base64Encode(userSignature),
    };
    print(dataSignature);
    var res = await SanctumApi().sendPost(
      data: dataSignature,
      apiURL: 'permits/' + widget.permitID.toString() + '/same-device-signature',
      additionalHeaders: {},
      withToken: true,
    );
    var body = jsonDecode(res.body);

    setState(() {
      _isSaveButtonDisabled = false;
    });

    if (body['errors'] == null) {
      return true;
    }
    else {
      return false;
    }
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

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Tanda Tangan Atasan', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: isSuperiorFound
        ? _drawSignature()
        : _findSuperior(),
    );
  }

  _findUser() async {
    setState(() {
      isBtnDisabled = true;
    });

    var res = await SanctumApi().sendGet(
      apiURL: 'users/' + userNik,
      additionalHeaders: {},
      withToken: true
    );
    var data = jsonDecode(res.body);
    if (data['errors'] == null) {
      userName = data['result']['user']['name'];
      userID = data['result']['user']['id'];

      var resCheck = await SanctumApi().sendGet(
        apiURL: 'permits/' + widget.permitID.toString() + '/check-give-signature?user_id=' + userID.toString(),
        additionalHeaders: {},
        withToken: true
      );
      var dataCheck = jsonDecode(resCheck.body);
      if (dataCheck['errors'] == null) {
        setState(() {
          fieldNikErrorText = null;
          isSuperiorFound = true;
        });
      }
      else {
        setState(() {
          fieldNikErrorText = dataCheck['message'];
          isSuperiorFound = false;
        });
      }

    }
    else {
      setState(() {
        fieldNikErrorText = data['message'];
        isSuperiorFound = false;
      });
    }

    setState(() {
      isBtnDisabled = false;
    });
    _selectFromSuggestion = false;
  }
}