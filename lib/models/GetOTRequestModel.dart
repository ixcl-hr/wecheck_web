class GetOTRequestModel {
  bool? flag;
  String? message;
  List<OTRequest> objectresult = [];

  GetOTRequestModel({this.flag, this.message, required this.objectresult});

  GetOTRequestModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      // objectresult = new List<OTRequest>();
      json['objectresult'].forEach((v) {
        objectresult.add(OTRequest.fromJson(v));
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

class OTRequest {
  int? otrequestid;
  String? employeecode;
  String? employeename;
  String? otdate;
  late String startdate;
  late String starttime;
  late String enddate;
  late String endtime;
  int? statusid;

  String? remark;
  String? isattachfile;
  bool? hasRemark;
  bool? hasAttachFile;

  OTRequest(
      this.otrequestid,
      this.employeecode,
      this.employeename,
      this.otdate,
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

  OTRequest.fromJson(Map<String, dynamic> json) {
    otrequestid = json['otrequestid'];
    employeecode = json['employeecode'];
    employeename = json['employeename'];
    otdate = json['otdate'];
    startdate = json['startdate'].toString();
    starttime = json['starttime'].toString();
    enddate = json['enddate'].toString();
    endtime = json['endtime'].toString();
    statusid = json['statusid'];

    remark = json['remark'];
    isattachfile = json['isattachfile'];
    hasRemark = remark != null && remark.toString().isNotEmpty;
    hasAttachFile = isattachfile != null && isattachfile == 'Y';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['otrequestid'] = otrequestid;
    data['employeecode'] = employeecode;
    data['employeename'] = employeename;
    data['otdate'] = otdate;
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
