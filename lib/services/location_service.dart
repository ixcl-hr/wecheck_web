import '../constants/config.dart';
import '../models/location.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class LocationService {
  static List<Location> locationList = [];

  Future<List<Location>> getLocation(
      {required Profile profile, required latitude, required longitude}) async {
    print('===>  LocationService');
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "latitude": latitude,
      "longitude": longitude,
      // "latitude": 13.627725,
      // "longitude": 100.474043,
      // "latitude": 15.1208863,
      // "longitude": 104.3122552
    });
    print('payload ===>  $payload');
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };

    var url = '${ApiMaster}GetLocation';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    if (response.statusCode == 200) {
      print("Data posted successfully");
      var feedback = convert.jsonDecode(response.body);
      print(feedback['objectresult']);
      final LocationModel location =
          LocationModel.fromJson(convert.jsonDecode(response.body));
      locationList = location.objectresult;
      return locationList;
    } else {
      print("Something went wrong! Status Code is: ${response.statusCode}");
      return locationList = [];
    }
  }
}
