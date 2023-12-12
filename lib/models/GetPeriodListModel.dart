import 'package:intl/intl.dart';
import 'dart:convert' as convert;

class GetPeriodListModel {
  bool? flag;
  String? message;
  List<Period> objectresult = [];

  GetPeriodListModel({this.flag, this.message, required this.objectresult});

  GetPeriodListModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      // ignore: deprecated_member_use
      objectresult = [];
      Map<String, dynamic> objectResultJson =
          convert.jsonDecode(json['objectresult']);
      if (objectResultJson['data'] != null) {
        objectResultJson['data'].forEach((v) {
          objectresult.add(Period.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    data['objectresult'] = objectresult.map((v) => v.toJson()).toList();
      return data;
  }
}

class Period {
  int? periodid;
  String? startdate;
  String? enddate;
  int? statusid;

  DateTime? startdatetime;
  DateTime? enddatetime;

  Period({this.periodid, this.startdate, this.enddate, this.statusid}) {
    startdatetime = startdate == null
        ? null
        : DateFormat('yyyy-MM-ddTHH:mm:ss').parse(startdate.toString());
    enddatetime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(enddate.toString());
  }

  Period.fromJson(Map<String, dynamic> json) {
    periodid = json['periodid'];
    startdate = json['startdate'];
    enddate = json['enddate'];
    statusid = json['statusid'];
    DateFormat dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
    if (startdate != null) {
      startdatetime = dateFormat.parse(startdate.toString());
    }
    if (enddate != null) {
      enddatetime = dateFormat.parse(enddate.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['periodid'] = periodid;
    data['startdate'] = startdate;
    data['enddate'] = enddate;
    data['statusid'] = statusid;
    return data;
  }

  String getStatus() {
    if (statusid == 5500001) {
      return 'เปิดงวด';
    } else if (statusid == 5500002) {
      return 'ปิดงวด';
    }
    return 'ทั้งหมด';
  }

  bool allowLoading() {
    return statusid == 5500002;
  }

  String getPeriodString() {
    return '${startdatetime == null
            ? ""
            : DateFormat('yyyy-MM-dd').format(startdatetime as DateTime)} - ${enddatetime == null
            ? ""
            : DateFormat('yyyy-MM-dd').format(enddatetime as DateTime)}';
  }
}
