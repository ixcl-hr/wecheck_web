import 'package:intl/intl.dart';

class GetMyAbsentRequestModel {
  bool? flag;
  String? message;
  List<MyAbsentRequest> objectresult = [];

  GetMyAbsentRequestModel(
      {this.flag, this.message, required this.objectresult});

  GetMyAbsentRequestModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      // objectresult = new List<MyAbsentRequest>();
      json['objectresult'].forEach((v) {
        objectresult.add(MyAbsentRequest.fromJson(v));
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

class MyAbsentRequest {
  int? absentrequestid;
  String? absenttype;
  String? startdate;
  String? starttime;
  String? enddate;
  String? endtime;
  int? statusid;
  String? remark;
  String? approvername;
  String? isattachfile;

  DateTime? startdatetime;
  DateTime? enddatetime;

  bool? hasRemark;
  bool? hasAttachFile;

  MyAbsentRequest(
      {this.absentrequestid,
      this.absenttype,
      this.startdate,
      this.starttime,
      this.enddate,
      this.endtime,
      this.statusid,
      this.remark,
      this.approvername,
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

  MyAbsentRequest.fromJson(Map<String, dynamic> json) {
    absentrequestid = json['absentrequestid'];
    absenttype = json['absenttype'];
    startdate = json['startdate'];
    starttime = json['starttime'];
    enddate = json['enddate'];
    endtime = json['endtime'];
    statusid = json['statusid'];
    remark = json['remark'];
    approvername = json['approvername'];
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
    data['absentrequestid'] = absentrequestid;
    data['absenttype'] = absenttype;
    data['startdate'] = startdate;
    data['starttime'] = starttime;
    data['enddate'] = enddate;
    data['endtime'] = endtime;
    data['statusid'] = statusid;
    data['remark'] = remark;
    data['approvername'] = approvername;
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
