import 'package:intl/intl.dart';
import '../constants/config.dart';
import '../models/GetMyAbsentRequestModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetMyAbsentRequestService {
  List<MyAbsentRequest> myAbsentRequest = [];
  var dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final int _selectedYear;

  GetMyAbsentRequestService(this._selectedYear);

  Future onRequest({required Profile profile}) async {
    DateTime yesterday = DateTime(_selectedYear, 1, 1);
    DateTime tomorrow = DateTime(_selectedYear, 12, 31);

    yesterday = yesterday.subtract(const Duration(days: 31));
    var yesterday0 = DateFormat('dd/MM/yyyy').format(yesterday);
    tomorrow = tomorrow.add(const Duration(days: 31));
    var tomorrow0 = DateFormat('dd/MM/yyyy').format(tomorrow);

    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": yesterday0,
      "enddate": tomorrow0,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetMyAbsentRequest';
    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      //print(_response.body);
      GetMyAbsentRequestModel feedback =
          GetMyAbsentRequestModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return myAbsentRequest = feedback.objectresult;
      }
    } catch (e) {
      print(e);
      return myAbsentRequest;
    }
  }
}
