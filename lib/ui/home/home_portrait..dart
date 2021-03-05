import 'dart:async';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc_event.dart';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc_state.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_pop_menu.dart';
import 'package:YOURDRS_FlutterAPP/network/models/schedule.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/patient_details.dart';
import 'package:YOURDRS_FlutterAPP/widget/date_range_picker.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/dictation.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/location.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/provider.dart';
import 'package:YOURDRS_FlutterAPP/widget/input_fields/search_bar.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePortrait extends StatefulWidget {
  HomePortrait({key}) : super(key: key);
  @override
  _HomePortraitState createState() => _HomePortraitState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _HomePortraitState extends State<HomePortrait> {
  GlobalKey _key = GlobalKey();
  final _debouncer = Debouncer(milliseconds: 500);

  Map<String, dynamic> appointment;
  var _currentSelectedProviderId;
  var _currentSelectedLocationId;
  var _currentSelectedDictationId;

  List<ScheduleList> patients = List();
  List<ScheduleList> filteredPatients = List();

  String startDate;
  String endDate;
  bool visibleSearchFilter = false;
  bool visibleClearFilter = true;
  String codeDialog;
  String valueText;

  TextEditingController _textFieldController = TextEditingController();
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PatientBloc>(context).add(GetSchedulePatientsList(
        keyword1: null,
        providerId: null,
        locationId: null,
        dictationId: null,
        startDate: null,
        endDate: null));
  }

//filter method  for selected date

//Date Picker Controller related code
  DatePickerController _controller = DatePickerController();

  DateTime _selectedValue = DateTime.now();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomizedColors.primaryColor,
        title: ListTile(
          leading: CircleAvatar(
            radius: 18,
            child: ClipOval(
              child: Image.network(
                  "https://image.freepik.com/free-vector/doctor-icon-avatar-white_136162-58.jpg"),
            ),
          ),
          title: Row(
            children: [
              Text(
                "Welcome",
                style: TextStyle(
                  color: CustomizedColors.textColor,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Dr.sciliaris",
                style: TextStyle(
                    color: CustomizedColors.textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Column(
            children: [
              Offstage(
                offstage: visibleSearchFilter,
                key: _key,
                child: FlatButton(
                  minWidth: 2,
                  padding: EdgeInsets.only(right: 0),
                  child: Icon(
                    visibleClearFilter != false ? Icons.segment : Icons.filter,
                    color: CustomizedColors.iconColor,
                  ),
                  onPressed: () {
                    return showDialog(
                      context: context,
                      builder: (ctx) => ListView(
                        children: [
                          AlertDialog(
                            title: Text(
                              "Select a filter",
                              style: TextStyle(),
                            ),
                            actions: <Widget>[
                              ProviderDropDowns(
                                selectedValue: _currentSelectedProviderId,
                                onTap: (String newValue) {
                                  print('onTap newValue $newValue');

                                  // setState(() {

                                  _currentSelectedProviderId = newValue;

                                  print(
                                      'onTap _currentSelectedProviderId $_currentSelectedProviderId');

                                  // });
                                },
                              ),
                              Dictation(onTapOfDictation: (String newValue) {
                                setState(() {
                                  _currentSelectedDictationId = newValue;

                                  print(_currentSelectedDictationId);
                                });
                              }),
                              LocationDropDown(
                                  onTapOfLocation: (String newValue) {
                                // setState(() {

                                _currentSelectedLocationId = newValue;

                                print(_currentSelectedLocationId);

                                // });
                              }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 55,
                                    width: 245,
                                    margin: EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color: CustomizedColors
                                                .homeSubtitleColor)),
                                    child: RaisedButton.icon(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        onPressed: () async {
                                          final List<String> result =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DateFilter()));

                                          startDate = result.first;

                                          endDate = result.last;

                                          print("range1" + startDate);

                                          print("range2" + endDate);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        label: Text(
                                          'Date Filter',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: CustomizedColors
                                                  .buttonTitleColor),
                                        ),
                                        icon: Icon(Icons.date_range),

                                        // textColor: Colors.red,

                                        splashColor:
                                            CustomizedColors.primaryColor,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 55,
                                    width: 245,
                                    margin: EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color: CustomizedColors
                                                .homeSubtitleColor)),
                                    child: RaisedButton.icon(
                                        padding: EdgeInsets.only(left: 25),
                                        onPressed: () {
                                          return showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Search Patients'),
                                                  content: TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        valueText = value;

                                                        print(valueText);
                                                      });
                                                    },
                                                    controller: this
                                                        ._textFieldController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            "Search Patients"),
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      color: CustomizedColors
                                                          .accentColor,
                                                      textColor: Colors.white,
                                                      child: Text('CANCEL'),
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      },
                                                    ),
                                                    FlatButton(
                                                      color: CustomizedColors
                                                          .accentColor,
                                                      textColor: Colors.white,
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        setState(() {
                                                          codeDialog =
                                                              valueText;

                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        label: Text(
                                          "Search Patient" ??
                                              "${this._textFieldController.text}",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: CustomizedColors
                                                .buttonTitleColor,
                                          ),
                                        ),
                                        icon: Icon(Icons.search),
                                        splashColor:
                                            CustomizedColors.primaryColor,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 55,
                                    width: 245,
                                    margin: EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color: CustomizedColors
                                                .homeSubtitleColor)),
                                    child: RaisedButton.icon(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        onPressed: () {
                                          setState(() {
                                            visibleSearchFilter = false;

                                            visibleClearFilter = true;
                                          });

                                          Navigator.pop(context);

                                          BlocProvider.of<PatientBloc>(context)
                                              .add(GetSchedulePatientsList(
                                                  keyword1: null,
                                                  providerId: null,
                                                  locationId: null,
                                                  dictationId: null,
                                                  startDate: null,
                                                  endDate: null,
                                                  searchString: null));
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        label: Text(
                                          'Clear Filter',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: CustomizedColors
                                                  .buttonTitleColor),
                                        ),
                                        icon: Icon(Icons.filter_alt_sharp),

                                        // textColor: Colors.red,

                                        splashColor:
                                            CustomizedColors.primaryColor,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      setState(() {
                                        visibleSearchFilter = true;

                                        visibleClearFilter = false;
                                      });

                                      BlocProvider.of<PatientBloc>(context).add(
                                          GetSchedulePatientsList(
                                              keyword1: null,
                                              providerId: _currentSelectedProviderId !=
                                                      null
                                                  ? int.tryParse(
                                                      _currentSelectedProviderId)
                                                  : null,
                                              locationId:
                                                  _currentSelectedLocationId !=
                                                          null
                                                      ? int.tryParse(
                                                          _currentSelectedLocationId)
                                                      : null,
                                              dictationId:
                                                  _currentSelectedDictationId !=
                                                          null
                                                      ? int.tryParse(
                                                          _currentSelectedDictationId)
                                                      : null,
                                              startDate:
                                                  startDate !=
                                                          ""
                                                      ? startDate
                                                      : null,
                                              endDate: endDate != ""
                                                  ? endDate
                                                  : null,
                                              searchString: this
                                                          ._textFieldController
                                                          .text !=
                                                      null
                                                  ? this._textFieldController.text
                                                  : null));
                                    },
                                    child: Text('Ok'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
//
                  },
                ),
              ),
              Offstage(
                offstage: visibleClearFilter,
                child: FlatButton(
                  minWidth: 2,
                  padding: EdgeInsets.only(right: 0),
                  child: Icon(
                    Icons.clear_all,
                    color: CustomizedColors.iconColor,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          "Select a filter",
                          style: TextStyle(),
                        ),
                        actions: <Widget>[
                          ProviderDropDowns(
                            selectedValue: _currentSelectedProviderId,
                            onTap: (String newValue) {
                              print('onTap newValue $newValue');
                              // setState(() {
                              _currentSelectedProviderId = newValue;
                              print(
                                  'onTap _currentSelectedProviderId $_currentSelectedProviderId');
                              // });
                            },
                          ),
                          Dictation(onTapOfDictation: (String newValue) {
                            setState(() {
                              _currentSelectedDictationId = newValue;
                              print(_currentSelectedDictationId);
                            });
                          }),
                          LocationDropDown(onTapOfLocation: (String newValue) {
                            // setState(() {
                            _currentSelectedLocationId = newValue;
                            print(_currentSelectedLocationId);
                            // });
                          }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 55,
                                width: 250,
                                child: RaisedButton.icon(
                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DateFilter()));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    label: Text(
                                      'Date Filter',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: CustomizedColors
                                              .buttonTitleColor),
                                    ),
                                    icon: Icon(null),
                                    // textColor: Colors.red,
                                    splashColor: CustomizedColors.primaryColor,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 55,
                                width: 250,
                                child: RaisedButton.icon(
                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    onPressed: () {
                                      setState(() {
                                        visibleSearchFilter = false;
                                        visibleClearFilter = true;
                                      });
                                      Navigator.pop(context);
                                      BlocProvider.of<PatientBloc>(context).add(
                                          GetSchedulePatientsList(
                                              keyword1: null,
                                              providerId: null,
                                              locationId: null,
                                              dictationId: null));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    label: Text(
                                      'Clear Filter',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: CustomizedColors
                                              .buttonTitleColor),
                                    ),
                                    icon: Icon(null),
                                    // textColor: Colors.red,
                                    splashColor: CustomizedColors.primaryColor,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    visibleSearchFilter = true;
                                    visibleClearFilter = false;
                                  });
                                  BlocProvider.of<PatientBloc>(context)
                                      .add(GetSchedulePatientsList(
                                    keyword1: null,
                                    providerId:
                                        _currentSelectedProviderId != null
                                            ? int.tryParse(
                                                _currentSelectedProviderId)
                                            : null,
                                    locationId:
                                        _currentSelectedLocationId != null
                                            ? int.tryParse(
                                                _currentSelectedLocationId)
                                            : null,
                                    dictationId:
                                        _currentSelectedDictationId != null
                                            ? int.tryParse(
                                                _currentSelectedDictationId)
                                            : null,
                                  ));
                                },
                                child: Text('Ok'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        //color: Colors.black,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.10,
              color: CustomizedColors.primaryColor,
            ),
            Positioned(
              top: 45,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Column(
                  children: <Widget>[
                    PatientSerach(
                      width: 250,
                      height: 60,
                      onChanged: (string) {
                        // isSearching = true;
                        _debouncer.run(() {
                          BlocProvider.of<PatientBloc>(context)
                              .add(SearchPatientEvent(keyword: string));
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.grey[100],
                      child: DatePicker(
                        DateTime.now().subtract(Duration(days: 3)),
                        width: 45.0,
                        height: 80,
                        controller: _controller,
                        initialSelectedDate: DateTime.now(),
                        selectionColor: CustomizedColors.primaryColor,
                        selectedTextColor: CustomizedColors.textColor,
                        dayTextStyle: TextStyle(fontSize: 10.0),
                        dateTextStyle: TextStyle(fontSize: 14.0),
                        onDateChange: (date) {
                          // New date selected
                          setState(() {
                            _selectedValue = date;
                            var selectedDate = AppConstants.parseDate(
                                -1, AppConstants.MMDDYYYY,
                                dateTime: _selectedValue);

                            // getSelectedDateAppointments();
                            BlocProvider.of<PatientBloc>(context).add(
                                GetSchedulePatientsList(
                                    keyword1: selectedDate,
                                    providerId: null,
                                    locationId: null,
                                    dictationId: null));
                            print(selectedDate);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Stack(
                children: <Widget>[
                  SafeArea(
                    bottom: false,
                    child: Stack(
                      children: <Widget>[
                        DraggableScrollableSheet(
                          maxChildSize: .7,
                          initialChildSize: .7,
                          minChildSize: .6,
                          builder: (context, scrollController) {
                            return Container(
                              height: 100,
                              padding: EdgeInsets.only(
                                  left: 19,
                                  right: 19,
                                  top:
                                      16), //symmetric(horizontal: 19, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                                color: CustomizedColors.textColor,
                              ),
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                controller: scrollController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "HEMA 54-DEAN (4)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        )
                                      ],
                                    ),
                                    BlocBuilder<PatientBloc,
                                            PatientAppointmentBlocState>(
                                        builder: (context, state) {
                                      print('BlocBuilder state $state');
                                      if (state.isLoading) {
                                        return CircularProgressIndicator();
                                      }

                                      if (state.errorMsg != null &&
                                          state.errorMsg.isNotEmpty) {
                                        return Text(state.errorMsg);
                                      }

                                      if (state.patients == null ||
                                          state.patients.isEmpty) {
                                        return Text(
                                          "No patients found",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: CustomizedColors
                                                  .noAppointment),
                                        );
                                      }

                                      // if (!isSearching) {
                                      patients = state.patients;
                                      // }

                                      if (state.keyword != null &&
                                          state.keyword.isNotEmpty) {
                                        print(
                                            'patients ${patients?.length} filtered ${filteredPatients?.length}');
                                        filteredPatients = patients
                                            .where((u) => (u.patient.displayName
                                                .toLowerCase()
                                                .contains(state.keyword
                                                    .toLowerCase())))
                                            .toList();
                                      } else {
                                        filteredPatients = patients;
                                      }

                                      return filteredPatients != null &&
                                              filteredPatients.isNotEmpty
                                          ? ListView.separated(
                                              separatorBuilder:
                                                  (context, index) => Divider(
                                                color: CustomizedColors.title,
                                              ),
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  filteredPatients.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Hero(
                                                  tag: filteredPatients[index],
                                                  child: Material(
                                                    child: ListTile(
                                                      contentPadding:
                                                          EdgeInsets.all(0),
                                                      leading: Icon(
                                                        Icons.bookmark,
                                                        color: Colors.green,
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PatientDetail(),
                                                            // Pass the arguments as part of the RouteSettings. The
                                                            // DetailScreen reads the arguments from these settings.
                                                            settings:
                                                                RouteSettings(
                                                              arguments:
                                                                  filteredPatients[
                                                                      index],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      title: Text(
                                                          filteredPatients[
                                                                  index]
                                                              .patient
                                                              .displayName),
                                                      subtitle: Column(
                                                        children: [
                                                          Container(
                                                            child: Text("Dr." +
                                                                    "" +
                                                                    filteredPatients[
                                                                            index]
                                                                        .providerName ??
                                                                ""),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                child: Text(
                                                                    filteredPatients[index]
                                                                            .appointmentType ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.0)),
                                                              ),
                                                              Container(
                                                                width: 75,
                                                                child: Text(
                                                                  filteredPatients[
                                                                              index]
                                                                          .appointmentStatus ??
                                                                      "",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12.0),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      trailing: Column(
                                                        children: [
                                                          Spacer(),
                                                          Spacer(),
                                                          RichText(
                                                            text: TextSpan(
                                                              text: '• ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 14),
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text: 'Dictation' +
                                                                            filteredPatients[index].dictationStatus ??
                                                                        ""),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              //   child: Text(
                                              //   "No Results Found",
                                              //   style: TextStyle(
                                              //       fontSize: 18.0,
                                              //       fontWeight: FontWeight.bold,
                                              //       color: CustomizedColors
                                              //           .noAppointment),
                                              // )
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              50, 25, 50, 45)),
                                                  Text(
                                                    "No results found for related search",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: CustomizedColors
                                                            .noAppointment),
                                                  )
                                                ],
                                              ),
                                            );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                    backgroundColor: CustomizedColors.primaryColor,
                    onPressed: () {},
                    tooltip: 'Increment',
                    child: Pop(
                      initialValue: 1,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
