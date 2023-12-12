import 'package:intl/intl.dart';
import '../constants/config.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetAdjustRequestService {
  AdjustRequest? adjustRequest;

  Future getRequest(
      {required Profile profile, required int adjustRequestId}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "adjustrequestid": adjustRequestId,
    });

    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetAdjustRequest';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);

      Map<String, dynamic> feedback = convert.jsonDecode(response.body);
      if (feedback['flag'] == true) {
        return adjustRequest = AdjustRequest.fromJson(feedback['objectresult']);
      } else {
        return adjustRequest = null;
      }
    } catch (e) {
      print(e);
    }
  }
}

class AdjustRequest {
  int? adjustrequestid;
  int? scanid;

  String? oldlocationname;
  String? oldscandatestring;
  String? oldscantimestring;
  DateTime? oldscandatetime;
  bool? oldisactive;

  bool? isgpsscan;
  bool? iswifiscan;
  bool? isqrcodescan;

  String? newlocationid;
  String? newscandatestring;
  String? newscantimestring;
  DateTime? newscandatetime;
  bool? newisactive;

  String? approvername;
  String? remark;
  bool? isattachfile;

  AdjustRequest(
    this.adjustrequestid,
    this.scanid,
    this.oldlocationname,
    this.oldscandatestring,
    this.oldscantimestring,
    this.oldscandatetime,
    this.oldisactive,
    this.isgpsscan,
    this.iswifiscan,
    this.isqrcodescan,
    this.newlocationid,
    this.newscandatestring,
    this.newscantimestring,
    this.newscandatetime,
    this.newisactive,
    this.approvername,
    this.remark,
    this.isattachfile,
  );

  AdjustRequest.fromJson(Map<String, dynamic> json) {
    adjustrequestid = json['adjustrequestid'];
    scanid = json['scanid'];

    oldlocationname = json['oldlocationname'];
    oldscandatestring = json['oldscandate'];
    oldscantimestring = json['oldscantime'];
    if (json['oldisactive'] == null) {
      oldisactive = null;
    } else if (json['oldisactive'] == 'Y') {
      oldisactive = true;
    } else if (json['oldisactive'] == 'N') {
      oldisactive = false;
    } else {
      oldisactive = null;
    }

    isgpsscan =
        json['isgpsscan'] != null && json['isgpsscan'] == 'Y' ? true : false;
    iswifiscan =
        json['iswifiscan'] != null && json['iswifiscan'] == 'Y' ? true : false;
    isqrcodescan = json['isqrcodescan'] != null && json['isqrcodescan'] == 'Y'
        ? true
        : false;

    newlocationid = json['newlocationid'];
    newscandatestring = json['newscandate'];
    newscantimestring = json['newscantime'];
    if (json['newisactive'] == null) {
      newisactive = null;
    } else if (json['newisactive'] == 'Y') {
      newisactive = true;
    } else if (json['newisactive'] == 'N') {
      newisactive = false;
    } else {
      newisactive = null;
    }

    approvername = json['approvername'];
    remark = json['remark'];
    isattachfile = json['isattachfile'] != null && json['isattachfile'] == 'Y'
        ? true
        : false;

    DateFormat dateFormat = DateFormat('dd/MM/yy HH:mm');
    try {
      oldscandatetime = dateFormat
          .parse('${oldscandatestring ?? ""} ${oldscantimestring ?? ""}');
    } catch (_) {
      oldscandatetime = null;
    }

    try {
      newscandatetime = dateFormat
          .parse('${newscandatestring ?? ""} ${newscantimestring ?? ""}');
    } catch (_) {
      newscandatetime = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }
}
