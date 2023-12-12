import 'package:intl/intl.dart';

class HistoryModel {
  bool? flag;
  String? message;
  List<History> objectresult = [];

  HistoryModel({this.flag, this.message, required this.objectresult});

  HistoryModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(History.fromJson(v));
      });
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

class History {
  int? scanid;
  String? scantype;
  String? scandate;
  String? scantime;
  String? locationcaption;
  String? needgps;
  String? needwifi;
  String? needqrcode;
  double? latitude;
  double? longitude;
  String? routerssid;
  String? routermacaddress;
  String? remark;
  String? isattachfile;

  History(
      {this.scanid,
      this.scantype,
      this.scandate,
      this.scantime,
      this.locationcaption,
      this.needgps,
      this.needqrcode,
      this.needwifi,
      this.latitude,
      this.longitude,
      this.routerssid,
      this.routermacaddress,
      this.remark,
      this.isattachfile});

  History.fromJson(Map<String, dynamic> json) {
    scanid = json['scanid'];
    scantype = json['scantype'];
    scandate = json['scandate'];
    scantime = json['scantime'];
    locationcaption = json['locationcaption'];
    needgps = json['needgps'];
    needqrcode = json['needqrcode'];
    needwifi = json['needwifi'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    routerssid = json['routerssid'];
    routermacaddress = json['routermacaddress'];
    remark = json['remark'];
    isattachfile = json['isattachfile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['scanid'] = scanid;
    data['scantype'] = scantype;
    data['scandate'] = scandate;
    data['scantime'] = scantime;
    data['locationcaption'] = locationcaption;
    data['needgps'] = needgps;
    data['needqrcode'] = needqrcode;
    data['needwifi'] = needwifi;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['routerssid'] = routerssid;
    data['routermacaddress'] = routermacaddress;
    data['remark'] = remark;
    data['isattachfile'] = isattachfile;
    return data;
  }

  DateTime toDateTime() {
    DateTime d = DateTime.parse(scandate ?? "");
    DateTime t = DateTime.parse(scantime ?? "");
    return DateTime(
      d.year,
      d.month,
      d.day,
      t.hour,
      t.minute,
      t.second,
      t.millisecond,
      t.microsecond,
    );
  }

  String dateTimeToString({String stringFormat = "dd/MM/yyyy HH:mm"}) {
    DateFormat dateFormat = DateFormat(stringFormat);
    return dateFormat.format(toDateTime());
  }

  bool isNeedGps() {
    return needgps != null && needgps == 'Y';
  }

  bool isNeedWifi() {
    return needwifi != null && needwifi == 'Y';
  }

  bool isNeedQrCode() {
    return needqrcode != null && needqrcode == 'Y';
  }
}
