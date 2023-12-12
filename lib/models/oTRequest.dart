import 'package:intl/intl.dart';

class MyOTRequestModel {
  bool? flag;
  String? message;
  List<MyOTRequest> objectresult = [];

  MyOTRequestModel({this.flag, this.message, required this.objectresult});

  MyOTRequestModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(MyOTRequest.fromJson(v));
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

class MyOTRequest {
  int? otrequestid;
  String? otdate;
  String? startdate;
  String? starttime;
  String? enddate;
  String? endtime;
  int? statusid;
  String? approvername;
  String? remark;
  String? isattachfile;

  DateTime? startdatetime;
  DateTime? enddatetime;

  bool? hasRemark;
  bool? hasAttachFile;

  MyOTRequest(
      {this.otrequestid,
      this.otdate,
      this.startdate,
      this.starttime,
      this.enddate,
      this.endtime,
      this.statusid,
      this.approvername,
      this.remark,
      this.isattachfile}) {
    startdatetime = startdate == null || starttime == null
        ? null
        : (DateFormat('yyyy-MM-ddTHH:mm:ss').parse(
            startdate.toString().substring(0, 11) +
                starttime.toString().substring(11)));
    enddatetime = enddate == null || endtime == null
        ? null
        : (DateFormat('yyyy-MM-ddTHH:mm:ss').parse(
            enddate.toString().substring(0, 11) +
                endtime.toString().substring(11)));
    hasRemark = remark != null && remark.toString().isNotEmpty;
    hasAttachFile = isattachfile != null && isattachfile == 'Y';
  }

  MyOTRequest.fromJson(Map<String, dynamic> json) {
    otrequestid = json['otrequestid'];
    otdate = json['otdate'];
    startdate = json['startdate'];
    starttime = json['starttime'];
    enddate = json['enddate'];
    endtime = json['endtime'];
    statusid = json['statusid'];
    approvername = json['approvername'];
    remark = json['remark'];
    isattachfile = json['isattachfile'];

    startdatetime = startdate == null || starttime == null
        ? null
        : (DateFormat('yyyy-MM-ddTHH:mm:ss').parse(
            startdate.toString().substring(0, 11) +
                starttime.toString().substring(11)));
    enddatetime = enddate == null || endtime == null
        ? null
        : (DateFormat('yyyy-MM-ddTHH:mm:ss').parse(
            enddate.toString().substring(0, 11) +
                endtime.toString().substring(11)));
    hasRemark = remark != null && remark.toString().isNotEmpty;
    hasAttachFile = isattachfile != null && isattachfile == 'Y';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['otrequestid'] = otrequestid;
    data['otdate'] = otdate;
    data['startdate'] = startdate;
    data['starttime'] = starttime;
    data['enddate'] = enddate;
    data['endtime'] = endtime;
    data['statusid'] = statusid;
    data['approvername'] = approvername;
    data['remark'] = remark;
    data['isattachfile'] = isattachfile;
    return data;
  }

  String getStartdate({String pattern = 'dd/MM/yyyy'}) {
    return startdatetime == null
        ? ""
        : DateFormat(pattern).format(startdatetime as DateTime);
  }

  String getEnddate({String pattern = 'dd/MM/yyyy'}) {
    return enddatetime == null
        ? ""
        : DateFormat(pattern).format(enddatetime as DateTime);
  }

  String getStarttime({String pattern = 'HH:mm'}) {
    return startdatetime == null
        ? ""
        : DateFormat(pattern).format(startdatetime as DateTime);
  }

  String getEndtime({String pattern = 'HH:mm'}) {
    return enddatetime == null
        ? ""
        : DateFormat(pattern).format(enddatetime as DateTime);
  }
}
