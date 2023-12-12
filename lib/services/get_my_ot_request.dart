import 'package:intl/intl.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/oTRequest.dart';
import '../models/profile.dart';

class GetMyOTRequest {
  List<MyOTRequest> myOTRequest = [];

  Future getMyOTRequest(
      {required Profile profile,
      DateTime? startdate,
      DateTime? enddate}) async {
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
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetMyOTRequest';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print('GetMyOTRequest');
      print(response.body);
      MyOTRequestModel feedback =
          MyOTRequestModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return myOTRequest = feedback.objectresult;
      } else {
        return myOTRequest;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
