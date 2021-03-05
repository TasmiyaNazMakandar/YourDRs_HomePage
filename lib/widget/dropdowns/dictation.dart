import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/dropdowns.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Dictation extends StatefulWidget {
  final onTapOfDictation;
  Dictation({@required this.onTapOfDictation});
  @override
  _DictationState createState() => _DictationState();
}

class _DictationState extends State<Dictation> {
  var _currentSelectedValue;
  final String url = "https://jsonplaceholder.typicode.com/users";

  List data = List(); //edited line
  Future<String> getDictationStatus() async {
    String jsonData = await DefaultAssetBundle.of(context)
        .loadString(AppStrings.dictationJson);
    final jsonResult = json.decode(jsonData);
    print(jsonResult);
    data = jsonResult;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // this.getSWData();
    this.getDictationStatus();
  }

  @override
  Widget build(BuildContext context) {
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
                        hint: "Dictation",
                        onChanged: (value) {
                          setState(() {
                            _currentSelectedValue = value;
                          });
                          widget.onTapOfDictation(value);
                        },
                        items: data.map((item) {
                          return DropdownMenuItem<String>(
                            child: new Text(item['dictationstatus']),
                            value: item['dictationstatusid'].toString(),
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
