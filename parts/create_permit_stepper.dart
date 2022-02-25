import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import './create_permit_confirm_dialog.dart';
import 'dart:async';

class CreatePermitStepper extends StatefulWidget {
  var token, userID, userName, userNIK;
  Function toggleLoadingStatus;
  Function permitCreated;
  CreatePermitStepper({this.token, this.userID, this.userName, this.userNIK, required this.toggleLoadingStatus, required this.permitCreated});

  @override
  State<CreatePermitStepper> createState() => _CreatePermitStepperState();
}

class _CreatePermitStepperState extends State<CreatePermitStepper> {
  var step1State = StepState.editing;
  var step2State = StepState.editing;
  var step3State = StepState.editing;
  var step4State = StepState.editing;
  var step5State = StepState.editing;

  var step1Active = false;
  var step2Active = false;
  var step3Active = false;
  var step4Active = false;
  var step5Active = false;

  final _step2FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  int _currentStep = 0;
  int _totalStep = 5 - 1;

  // var currentTime = new DateTime.now();
  var currentTime = new DateTime.now();
  var currentTimePlusOneHour = new DateTime.now().add(new Duration(hours: 1));

  var submittedData;

  final fieldControllerDateFrom = TextEditingController(text: new DateFormat('dd/MM/yyyy').format(new DateTime.now()));
  final fieldControllerTimeFrom = TextEditingController(text: new DateFormat('H').format(new DateTime.now().add(new Duration(hours: 1))) + ':00',);
  final fieldControllerDateTo = TextEditingController(text: new DateFormat('dd/MM/yyyy').format(new DateTime.now()));
  final fieldControllerTimeTo = TextEditingController();
  final fieldControllerPermitExcuse = TextEditingController();

  DateTime fieldDateFromDefaultDate = DateTime.now();
  fieldDateFromChanger(newValue) {
    setState(() {
      fieldDateFromDefaultDate = newValue;
    });
  }

  DateTime fieldDateToDefaultDate = DateTime.now();
  fieldDateToChanger(newValue) {
    setState(() {
      fieldDateToDefaultDate = newValue;
    });
  }

  Future<Null> _fieldSelectDate(BuildContext context, fieldController, defaultValue, defaultValueChanger) async {
    var picked = await showDatePicker(
      context: context,
      initialDate: defaultValue,
      firstDate: DateTime(2022, 1),
      lastDate: DateTime(2030, 12),
    );
    if (picked != null && picked != defaultValue) {
      defaultValueChanger(picked);
      setState(() {
        fieldController.value = TextEditingValue(text: new DateFormat('dd/MM/yyyy').format(picked));
      });
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Buat Izin', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Stepper(
            physics : ClampingScrollPhysics(),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Container(
                margin: EdgeInsets.only(top: 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: _currentStep < _totalStep
                        ? FxButton.small(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            onPressed: details.onStepContinue,
                            elevation: 0,
                            child: FxText.b2(
                              'BERIKUTNYA',
                              color: AppTheme.theme.colorScheme.onPrimary,
                            ),
                            borderRadiusAll: 4,
                            backgroundColor: AppTheme.theme.colorScheme.primary,
                          )
                        : FxButton.small(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            onPressed: details.onStepContinue,
                            elevation: 0,
                            child: FxText.b2(
                              'OK',
                              color: AppTheme.theme.colorScheme.onPrimary,
                            ),
                            borderRadiusAll: 4,
                            backgroundColor: AppTheme.theme.colorScheme.primary,
                          )
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(start: 8),
                      child: _currentStep > 0
                        ? TextButton(
                            onPressed: details.onStepCancel, 
                            child: Text('SEBELUMNYA')
                          )
                        : Text('')
                    ),
                  ],
                ),
              );
            },
            currentStep: _currentStep,
            onStepContinue: () async {

              if (_currentStep == 0) {
                setState(() {
                  step1State = StepState.complete;
                  step1Active = true;
                });
              }

              if (_currentStep == 1) {
                if (_step2FormKey.currentState!.validate()) {
                  setState(() {
                    step2State = StepState.complete;
                    step2Active = true;
                  });
                }
                else {
                  setState(() {
                    step2State = StepState.editing;
                    step2Active = false;
                  });
                  return;
                }
              }

              if (_currentStep == 2) {
                setState(() {
                  step3State = StepState.complete;
                  step3Active = true;
                });
              }

              if (_currentStep == 3) {
                if (_step4FormKey.currentState!.validate()) {
                  setState(() {
                    step4State = StepState.complete;
                    step4Active = true;
                  });
                }
                else {
                  setState(() {
                    step4State = StepState.editing;
                    step4Active = false;
                  });
                  return;
                }
              }

              if (_currentStep == 4) {
                if (_signatureController.isNotEmpty) {
                  setState(() {
                    step5State = StepState.complete;
                    step5Active = true;
                  });

                  if (step1Active && step2Active && step3Active && step4Active && step5Active) {
                    submittedData = {
                      'user_id': widget.userID,
                      'date_from': fieldControllerDateFrom.text,
                      'time_from': fieldControllerTimeFrom.text,
                      'date_to': fieldControllerDateTo.text,
                      'time_to': fieldControllerTimeTo.text,
                      'permit_excuse': fieldControllerPermitExcuse.text,
                      'user_signature': await _signatureController.toPngBytes(),
                    };
                    await showDialog(context: context, builder: (BuildContext build) => CreatePermitConfirmDialog(
                      toggleLoadingStatus: widget.toggleLoadingStatus,
                      submittedData: submittedData,
                      permitCreated: widget.permitCreated
                    ));
                  }
                }
                else {
                  setState(() {
                    step5State = StepState.editing;
                    step5Active = false;
                  });
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

              if (_currentStep >= _totalStep) return;

              setState(() {
                _currentStep += 1;
              });
            },
            onStepCancel: () {
              if (_currentStep <= 0) return;
              setState(() {
                _currentStep -= 1;
              });
            },
            onStepTapped: (pos) {
              setState(() {
                _currentStep = pos;
              });
            },
            steps: <Step>[
              Step(
                isActive: step1Active,
                state: step1State,
                title: FxText.sh1('Data Diri', fontWeight: 600,),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      child: FxText.sh1('Nama', fontWeight: 500,),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 4),
                      child: FxText.b2(widget.userName),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 8),
                      child: FxText.sh1('NIK', fontWeight: 500,),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 4),
                      child: FxText.b2(widget.userNIK),
                    ),
                  ],
                ),
              ),
              Step(
                isActive: step2Active,
                state: step2State,
                title: FxText.sh1('Tanggal dan Jam Keluar', fontWeight: 600,),
                content: Form(
                  key: _step2FormKey,
                  child: Column(
                    children: [
                      Container(
                        // margin: EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () => _fieldSelectDate(context, fieldControllerDateFrom, fieldDateFromDefaultDate, fieldDateFromChanger),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: fieldControllerDateFrom,
                              decoration: InputDecoration(
                                labelText: 'Tanggal Keluar',
                                hintText: 'DD/MM/YYYY',
                                border: AppTheme.theme.inputDecorationTheme.border,
                                enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                                focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                                prefixIcon: Icon(
                                  MdiIcons.calendarBlankOutline,
                                  size: 24,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal keluar tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          controller: fieldControllerTimeFrom,
                          decoration: InputDecoration(
                            labelText: 'Jam Keluar',
                            hintText: 'HH:MM',
                            border: AppTheme.theme.inputDecorationTheme.border,
                            enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                            focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                            prefixIcon: Icon(
                              MdiIcons.clock,
                              size: 24,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jam keluar tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                
                    ],
                  ),
                ),
              ),
              Step(
                isActive: step3Active,
                state: step3State,
                title: FxText.sh1('Tanggal dan Jam Kembali', fontWeight: 600,),
                content: Column(
                  children: <Widget>[
                    Container(
                      // margin: EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () => _fieldSelectDate(context, fieldControllerDateTo, fieldDateToDefaultDate, fieldDateToChanger),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: fieldControllerDateTo,
                            decoration: InputDecoration(
                              labelText: 'Tanggal Kembali',
                              hintText: 'DD/MM/YYYY',
                              border: AppTheme.theme.inputDecorationTheme.border,
                              enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                              focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                              prefixIcon: Icon(
                                MdiIcons.calendarBlankOutline,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        controller: fieldControllerTimeTo,
                        decoration: InputDecoration(
                          labelText: 'Jam Kembali',
                          hintText: 'HH:MM',
                          border: AppTheme.theme.inputDecorationTheme.border,
                          enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                          focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                          prefixIcon: Icon(
                            MdiIcons.clock,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                isActive: step4Active,
                state: step4State,
                title: FxText.sh1('Detail', fontWeight: 600,),
                content: Form(
                  key: _step4FormKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: TextFormField(
                          controller: fieldControllerPermitExcuse,
                          decoration: InputDecoration(
                            labelText: 'Alasan',
                            border: AppTheme.theme.inputDecorationTheme.border,
                            enabledBorder: AppTheme.theme.inputDecorationTheme.border,
                            focusedBorder: AppTheme.theme.inputDecorationTheme.focusedBorder,
                            prefixIcon: Icon(
                              MdiIcons.leadPencil,
                              size: 24,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Alasan harus diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Step(
                isActive: step5Active,
                state: step5State,
                title: FxText.sh1('Tanda Tangan', fontWeight: 600,),
                content: Column(
                  children: [
                    Signature(
                      controller: _signatureController,
                      width: 300,
                      height: 200,
                      backgroundColor: Color.fromARGB(255, 255, 205, 210),
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
                                step5State = StepState.editing;
                                step5Active = false;
                              });
                            },
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
}