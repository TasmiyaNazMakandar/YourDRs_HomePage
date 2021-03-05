import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc_event.dart';
import 'package:YOURDRS_FlutterAPP/network/models/provider.dart';
import 'package:YOURDRS_FlutterAPP/network/services/appointment_service.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/dropdowns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProviderDropDowns extends StatefulWidget {
  final onTap;
  final String selectedValue;

  ProviderDropDowns({@required this.onTap, this.selectedValue});
  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<ProviderDropDowns> {
  String _currentSelectedValue;
  final String url = "https://jsonplaceholder.typicode.com/users";

  List data = List(); //edited line
  Services apiServices = Services();
  bool isInit = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (isInit) {
      isInit = false;
      Providers provider = await apiServices.getProviders();
      if (data.isEmpty) {
        setState(() {
          data = provider.providerList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build selectedValue ${widget.selectedValue}');
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 24),
            child: Container(
                height: 55,
                width: 245,
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _currentSelectedValue == '',
                      child: DropDown(
                        value: _currentSelectedValue,
                        hint: "Provider",
                        onChanged: (value) {
                          setState(() {
                            _currentSelectedValue = value;
                          });
                          print(
                              'onChanged _currentSelectedValue $_currentSelectedValue');
                          widget.onTap(_currentSelectedValue);
                        },
                        items: data.map((item) {
                          return DropdownMenuItem<String>(
                            child: new Text(item.displayname),
                            value: item.providerId.toString(),
                          );
                        }).toList(),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
