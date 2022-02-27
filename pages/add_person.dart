import 'dart:convert';

import 'package:epermits/network/sanctum_api.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPerson extends StatefulWidget {
  var permitID;

  AddPerson({required this.permitID});

  @override
  State<AddPerson> createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final _formKey = GlobalKey<FormState>();
  var fieldNikErrorText = null;
  final TextEditingController _fieldUserController = TextEditingController();
  var userNik, currentNik, userName, userID;
  bool isBtnDisabled = false;
  bool isUserFound = false;
  bool _selectFromSuggestion = false;

  _getCurrentNik() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    currentNik = localStorage.getString('userNIK');
  }

  @override
  initState() {
    super.initState();
    _getCurrentNik();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Tambah Orang', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: FxSpacing.nTop(20),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 12),
              child: FxText.sh1('Masukkan NIK atau nama', fontWeight: 600,),
            ),

            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  labelText: 'NIK',
                  border: AppTheme.theme.inputDecorationTheme.border,
                  enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                  focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                  prefixIcon: Icon(
                    MdiIcons.numeric,
                    size: 24,
                  ),
                  errorText: fieldNikErrorText,
                ),
                controller: this._fieldUserController,
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
                userNik = selectedData['nik'];
                this._fieldUserController.text = selectedData['name'] + ' (' + selectedData['nik'] + ')';
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
                  onPressed: () async {
                    if (!isBtnDisabled) {
                      if (_formKey.currentState!.validate()) {
                        await _findUser();
                        if (isUserFound) {
                          _processAddPerson();
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(FxSpacing.xy(16, 0)),
                  ),
                  child: FxText.button(
                    isBtnDisabled ? 'MEMPROSES...' : 'TAMBAHKAN',
                    fontWeight: 700,
                    color: AppTheme.theme.colorScheme.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _processAddPerson() async {
    showDialog(
      context: context,
      builder: (BuildContext build) => _addPersonDialog(),
    ).then((value) async {
      if (value) {
        setState(() {
          isBtnDisabled = true;
        });

        var dataAddPerson = {
          'user_id': userID
        };
        var res = await SanctumApi().sendPost(
          data: dataAddPerson,
          apiURL: 'permits/' + widget.permitID.toString() + '/add-person',
          additionalHeaders: {},
          withToken: true
        );
        var body = jsonDecode(res.body);

        setState(() {
          isBtnDisabled = false;
        });

        if (body['errors'] == null) {
          fieldNikErrorText = null;
          Navigator.pop(context);
        }
        else {
          fieldNikErrorText = body['message'];
        }
      }
    });
  }

  _addPersonDialog() {
    return AlertDialog(
      title: Text('Lanjutkan'),
      content: Text('Tambahkan $userName ($userNik) ke izin keluar Anda?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          }, 
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          child: Text('Tambahkan'),
        ),
      ],
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
      userNik = data['result']['user']['nik'];

      var resCheck = await SanctumApi().sendGet(
        apiURL: 'permits/' + widget.permitID.toString() + '/check-additional-user?user_id=' + userID.toString(),
        additionalHeaders: {},
        withToken: true
      );
      var dataCheck = jsonDecode(resCheck.body);
      if (dataCheck['errors'] == null) {
        setState(() {
          fieldNikErrorText = null;
          isUserFound = true;
        });
      }
      else {
        setState(() {
          fieldNikErrorText = dataCheck['message'];
          isUserFound = false;
        });
      }

    }
    else {
      setState(() {
        fieldNikErrorText = data['message'];
        isUserFound = false;
      });
    }

    setState(() {
      isBtnDisabled = false;
    });
    _selectFromSuggestion = false;
  }
}