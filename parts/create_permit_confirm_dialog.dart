import 'package:epermits/pages/view_permit.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import '../network/sanctum_api.dart';
import 'dart:convert';
import '../pages/view_permit.dart';

class CreatePermitConfirmDialog extends StatefulWidget {
  Function toggleLoadingStatus;
  var submittedData;
  Function permitCreated;

  CreatePermitConfirmDialog({required this.toggleLoadingStatus, required this.submittedData, required this.permitCreated});

  @override
  State<CreatePermitConfirmDialog> createState() => _CreatePermitConfirmDialogState();
}

class _CreatePermitConfirmDialogState extends State<CreatePermitConfirmDialog> {
  @override 
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Lanjutkan'),
      content: Text('Pastikan data sudah benar sebelum melanjutkan'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Batal');
          },
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Batal');
            widget.toggleLoadingStatus();
            print(widget.submittedData);

            widget.submittedData['user_signature'] = base64Encode(widget.submittedData['user_signature']);

            var res = await SanctumApi().sendPost(
              data: widget.submittedData,
              apiURL: 'permits',
              additionalHeaders: {},
              withToken: true
            );
            var body = jsonDecode(res.body);
            print(res.body);

            widget.toggleLoadingStatus();
            widget.permitCreated();
          },
          child: Text('Lanjutkan'),
        ),
      ],
    );
  }
}