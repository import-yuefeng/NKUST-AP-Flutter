import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/utils/utils.dart';

typedef SemesterCallback = void Function(Semester semester, int index);

class SemesterPicker extends StatefulWidget {
  final SemesterCallback onSelect;

  const SemesterPicker({Key key, this.onSelect}) : super(key: key);

  @override
  SemesterPickerState createState() => SemesterPickerState();
}

class SemesterPickerState extends State<SemesterPicker> {
  SemesterData semesterData;
  Semester selectSemester;

  @override
  void initState() {
    _getSemester();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        if (semesterData != null) pickSemester();
        FA.logAction('pick_yms', 'click');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            selectSemester?.text ?? '',
            style: TextStyle(
              color: Resource.Colors.semesterText,
              fontSize: 18.0,
            ),
          ),
          SizedBox(width: 8.0),
          Icon(
            Icons.keyboard_arrow_down,
            color: Resource.Colors.semesterText,
          )
        ],
      ),
    );
  }

  void _loadSemesterData() async {
    this.semesterData = await CacheUtils.loadSemesterData();
    if (this.semesterData == null) return;
    widget.onSelect(semesterData.defaultSemester, semesterData.defaultIndex);
    setState(() {
      selectSemester = semesterData.defaultSemester;
    });
  }

  void _getSemester() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      _loadSemesterData();
      return;
    }
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      CacheUtils.saveSemesterData(semesterData);
      if (mounted) {
        widget.onSelect(
            semesterData.defaultSemester, semesterData.defaultIndex);
        setState(() {
          selectSemester = semesterData.defaultSemester;
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getSemester', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            if (mounted) Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
      _loadSemesterData();
      //widget.onSelect(semesterData.defaultSemester, semesterData.defaultIndex);
    });
  }

  void pickSemester() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: Text(AppLocalizations.of(context).picksSemester),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        children: [
          for (var i = 0; i < semesterData.semesters.length; i++) ...[
            SimpleDialogOption(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      semesterData.semesters[i].text,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: (semesterData.semesters[i].text ==
                                  selectSemester.text)
                              ? Resource.Colors.blueAccent
                              : null),
                    ),
                    if (semesterData.semesters[i].text == selectSemester.text)
                      Icon(
                        Icons.check,
                        color: Resource.Colors.blueAccent,
                      )
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, i);
                }),
            Divider(
              height: 6.0,
            )
          ]
        ],
      ),
    ).then<void>((int position) async {
      if (position != null) {
        widget.onSelect(semesterData.semesters[position], position);
        setState(() {
          selectSemester = semesterData.semesters[position];
        });
      }
    });
  }
}
