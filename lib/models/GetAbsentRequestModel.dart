class GetAbsentRequestModel {
  bool? flag;
  String? message;
  List<AbsentRequest> objectresult = [];

  GetAbsentRequestModel({this.flag, this.message, required this.objectresult});

  GetAbsentRequestModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      // objectresult = new List<AbsentRequest>();
      json['objectresult'].forEach((v) {
        objectresult.add(AbsentRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    if (objectresult.isNotEmpty) {
      data['objectresult'] = objectresult.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AbsentRequest {
  int? absentrequestid;
  int? employeeId;
  String? employeecode;
  String? employeename;
  String? absenttype;
  String? startdate;
  String? starttime;
  String? enddate;
  String? endtime;
  int? statusid;
  String? remark;
  String? isattachfile;
  bool? hasRemark;
  bool? hasAttachFile;

  AbsentRequest(
      this.absentrequestid,
      this.employeeId,
      this.employeecode,
      this.employeename,
      this.absenttype,
      this.startdate,
      this.starttime,
      this.enddate,
      this.endtime,
      this.statusid,
      this.remark,
      this.isattachfile) {
    hasRemark = remark != null && remark.toString().isNotEmpty;
    hasAttachFile = isattachfile != null && isattachfile == 'Y';
  }

  AbsentRequest.fromJson(Map<String, dynamic> json) {
    absentrequestid = json['absentrequestid'];
    employeeId = json['employeeId'];
    employeecode = json['employeecode'];
    employeename = json['employeename'];
    absenttype = json['absenttype'];
    startdate = json['startdate'];
    starttime = json['starttime'];
    enddate = json['enddate'];
    endtime = json['endtime'];
    statusid = json['statusid'];
    remark = json['remark'];
    isattachfile = json['isattachfile'];
    hasRemark = remark != null && remark.toString().isNotEmpty;
    hasAttachFile = isattachfile != null && isattachfile == 'Y';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['absentrequestid'] = absentrequestid;
    data['employeeId'] = employeeId;
    data['employeecode'] = employeecode;
    data['employeename'] = employeename;
    data['absenttype'] = absenttype;
    data['startdate'] = startdate;
    data['starttime'] = starttime;
    data['enddate'] = enddate;
    data['endtime'] = endtime;
    data['statusid'] = statusid;
    data['remark'] = remark;
    data['isattachfile'] = isattachfile;
    return data;
  }
}
