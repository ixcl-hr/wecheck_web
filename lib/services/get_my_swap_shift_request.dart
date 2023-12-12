import 'package:intl/intl.dart';
import '../constants/config.dart';
import '../models/SwapShiftRequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetMySwapShiftRequestService {
  List<SwapShiftRequest> myRequest = [];

  Future<List<SwapShiftRequest>> GetMySwapShiftRequest({
    required Profile profile,
    required String Viewer,
    DateTime? startdate,
    DateTime? enddate,
  }) async {
    String startdate0 = '';
    String enddate0 = '';
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    if (startdate != null) {
      startdate0 = dateFormat.format(startdate);
    } else {
      DateTime yesterday = DateTime.now();
      yesterday = yesterday.subtract(const Duration(days: 31));
      startdate0 = dateFormat.format(yesterday);
    }

    if (enddate != null) {
      enddate0 = dateFormat.format(enddate);
    } else {
      DateTime tomorrow = DateTime.now();
      tomorrow = tomorrow.add(const Duration(days: 31));
      enddate0 = dateFormat.format(tomorrow);
    }

    print(startdate0);
    print(enddate0);

    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": startdate0,
      "enddate": enddate0,
      "viewer": Viewer,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetMySwapShiftRequest';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print('GetMySwapShiftRequest');
      //print(response.body);
      SwapShiftRequestModel feedback =
          SwapShiftRequestModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return myRequest = feedback.objectresult;
      } else {
        return myRequest;
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  unApprove({required Profile profile, required listRequest}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "requestidlist": listRequest
    });

    print("payload");
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}UnapproveSwapShift';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    //print(_response.body);
    if (response.statusCode == 200) {
      print("Unapprove successfully");
    } else {
      print("Unapprove went wrong! Status Code is: ${response.statusCode}");
    }
  }

  onApprove({required Profile profile, required listRequest}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "requestidlist": listRequest
    });

    print("payload");
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}ApproveSwapShift';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    print(response.body);
    if (response.statusCode == 200) {
      print("Approve successfully");
    } else {
      print("Approve went wrong! Status Code is: ${response.statusCode}");
    }
  }
}
