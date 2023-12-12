//import 'dart:ffi';

class GetWorkHistoryModel {
  bool? flag;
  String? message;
  List<WorkHistory> objectresult = [];

  GetWorkHistoryModel({this.flag, this.message, required this.objectresult});

  GetWorkHistoryModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(WorkHistory.fromJson(v));
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

class WorkHistory {
  int? worktype;
  String? workdate;
  String? startdate1;
  String? starttime1;
  String? starttemp1;
  String? enddate1;
  String? endtime1;
  String? endtemp1;
  String? startdate2;
  String? starttime2;
  String? starttemp2;
  String? enddate2;
  String? endtime2;
  String? endtemp2;
  String? absenttype;
  double? missinghour;

  String? wsstarttime1;
  String? wsendtime1;
  String? wsstarttime2;
  String? wsendtime2;

  WorkHistory(
      {this.worktype,
      this.workdate,
      this.startdate1,
      this.starttime1,
      this.starttemp1,
      this.enddate1,
      this.endtime1,
      this.endtemp1,
      this.startdate2,
      this.starttime2,
      this.starttemp2,
      this.enddate2,
      this.endtime2,
      this.endtemp2,
      this.absenttype,
      this.missinghour,
      this.wsstarttime1,
      this.wsendtime1,
      this.wsstarttime2,
      this.wsendtime2});

  WorkHistory.fromJson(Map<String, dynamic> json) {
    worktype = json['worktype'];
    workdate = json['workdate'];
    startdate1 = json['startdate1'];
    starttime1 = json['starttime1'];
    starttemp1 = json['starttemp1'];
    enddate1 = json['enddate1'];
    endtime1 = json['endtime1'];
    endtemp1 = json['endtemp1'];
    startdate2 = json['startdate2'];
    starttime2 = json['starttime2'];
    starttemp2 = json['starttemp2'];
    enddate2 = json['enddate2'];
    endtime2 = json['endtime2'];
    endtemp2 = json['endtemp2'];
    absenttype = json['absenttype'];
    missinghour = json['missinghour'];
    wsstarttime1 = json['wsstarttime1'];
    wsendtime1 = json['wsendtime1'];
    wsstarttime2 = json['wsstarttime2'];
    wsendtime2 = json['wsendtime2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['worktype'] = worktype;
    data['workdate'] = workdate;
    data['startdate1'] = startdate1;
    data['starttime1'] = starttime1;
    data['starttemp1'] = starttemp1;
    data['enddate1'] = enddate1;
    data['endtime1'] = endtime1;
    data['endtemp1'] = endtemp1;
    data['startdate2'] = startdate2;
    data['starttime2'] = starttime2;
    data['starttemp2'] = starttemp2;
    data['enddate2'] = enddate2;
    data['endtime2'] = endtime2;
    data['endtemp2'] = endtemp2;
    data['absenttype'] = absenttype;
    data['missinghour'] = missinghour;
    data['wsstarttime1'] = wsstarttime1;
    data['wsendtime1'] = wsendtime1;
    data['wsstarttime2'] = wsstarttime2;
    data['wsendtime2'] = wsendtime2;
    return data;
  }
}
