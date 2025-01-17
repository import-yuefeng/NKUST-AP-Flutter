import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';

class BusData {
  String date;
  List<BusTime> timetable;

  BusData({
    this.date,
    this.timetable,
  });

  factory BusData.fromRawJson(String str) => BusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusData.fromJson(Map<String, dynamic> json) => BusData(
        date: json["date"],
        timetable:
            List<BusTime>.from(json["data"].map((x) => BusTime.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "data": List<dynamic>.from(timetable.map((x) => x.toJson())),
      };

  static BusData sample() {
    return BusData.fromRawJson(
        '{ "date": "2019-03-17T16:51:57Z", "data": [ { "endEnrollDateTime": "2019-03-17T16:51:57Z", "departureTime": "2019-03-17T16:51:57Z", "startStation": "建工", "busId": "42705", "reserveCount": 2, "limitCount": 999, "isReserve": true, "specialTrain": "0", "discription": "", "cancelKey": "0", "homeCharteredBus": false }, { "endEnrollDateTime": "2020-03-17T16:51:57Z", "departureTime": "2020-03-17T16:51:57Z", "startStation": "建工", "busId": "42711", "reserveCount": 11, "limitCount": 999, "isReserve": false, "SpecialTrain": "0", "discription": "", "cancelKey": "0", "homeCharteredBus": false } ] }');
  }
}

class BusTime {
  String endEnrollDateTime;
  String departureTime;
  String startStation;
  String busId;
  int reserveCount;
  int limitCount;
  bool isReserve;
  String specialTrain;
  String description;
  String cancelKey;
  bool homeCharteredBus;

  BusTime({
    this.endEnrollDateTime,
    this.departureTime,
    this.startStation,
    this.busId,
    this.reserveCount,
    this.limitCount,
    this.isReserve,
    this.specialTrain,
    this.description,
    this.cancelKey,
    this.homeCharteredBus,
  });

  String getSpecialTrainTitle(AppLocalizations local) {
    switch (specialTrain) {
      case "1":
        return local.specialBus;
      case "2":
        return local.trialBus;
      default:
        return "";
    }
  }

//  String getSpecialTrainRemark() {
//    print(specialTrainRemark);
//    if (specialTrainRemark.length == 0)
//      return "";
//    else
//      return "${specialTrainRemark.replaceAll("\n", "").replaceAll("<br />", "\n")}\n";
//  }

  static List<BusTime> toList(List<dynamic> jsonArray) {
    List<BusTime> list = [];
    for (var item in (jsonArray ?? [])) list.add(BusTime.fromJson(item));
    return list;
  }

  factory BusTime.fromRawJson(String str) => BusTime.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusTime.fromJson(Map<String, dynamic> json) => BusTime(
        endEnrollDateTime: json["endEnrollDateTime"],
        departureTime: json["departureTime"],
        startStation: json["startStation"],
        busId: json["busId"],
        reserveCount: json["reserveCount"],
        limitCount: json["limitCount"],
        isReserve: json["isReserve"],
        specialTrain: json["specialTrain"],
        description: json["description"],
        cancelKey: json["cancelKey"],
        homeCharteredBus: json["homeCharteredBus"],
      );

  Map<String, dynamic> toJson() => {
        "endEnrollDateTime": endEnrollDateTime,
        "departureTime": departureTime,
        "startStation": startStation,
        "busId": busId,
        "reserveCount": reserveCount,
        "limitCount": limitCount,
        "isReserve": isReserve,
        "specialTrain": specialTrain,
        "description": description,
        "cancelKey": cancelKey,
        "homeCharteredBus": homeCharteredBus,
      };

  bool canReserve() {
    var now = DateTime.now();
    initializeDateFormatting();
    var formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var endEnrollDateTime = formatter.parse(this.endEnrollDateTime);
    return now.millisecondsSinceEpoch <=
        endEnrollDateTime.add(Duration(hours: 8)).millisecondsSinceEpoch;
  }

  String getEndEnrollDateTime() {
    initializeDateFormatting();
    var formatter = DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss ');
    var endEnrollDateTime = formatter.parse(this.endEnrollDateTime);
    return dateFormat.format(endEnrollDateTime.add(Duration(hours: 8)));
  }

  Color getColorState() {
    return isReserve
        ? Resource.Colors.blueAccent
        : canReserve() ? Resource.Colors.grey : Resource.Colors.disabled;
  }

  String getReserveState(AppLocalizations local) {
    return isReserve
        ? local.reserved
        : canReserve() ? local.reserve : local.canNotReserve;
  }

  String getDate() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    var formatterTime = new DateFormat('yyyy-MM-dd');
    var time = formatter.parse(this.departureTime);
    return formatterTime.format(time.add(Duration(hours: 8)));
  }

  String getTime() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    var formatterTime = new DateFormat('HH:mm', 'zh');
    var time = formatter.parse(this.departureTime);
    return formatterTime.format(time.add(Duration(hours: 8)));
  }

  String getStart(AppLocalizations local) {
    switch (startStation) {
      case "建工":
        return local.jiangong;
      case "燕巢":
        return local.yanchao;
      default:
        return local.unknown;
    }
  }

  String getEnd(AppLocalizations local) {
    switch (startStation) {
      case "建工":
        return local.yanchao;
      case "燕巢":
        return local.jiangong;
      default:
        return local.unknown;
    }
  }
}
