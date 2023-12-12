class LocationModel {
  bool? flag;
  String? message;
  List<Location> objectresult = [];

  LocationModel({this.flag, this.message, required this.objectresult});

  LocationModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(Location.fromJson(v));
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

class Location {
  int? locationid;
  String? locationcaption;
  String? range;
  String? needgps;
  String? needqrcode;
  String? needwifi;
  String? needcameraimg;
  String? checkgps;
  String? checkqrcode;
  String? checkwifi;

  Location(
      {this.locationid,
      this.locationcaption,
      this.range,
      this.needgps,
      this.needqrcode,
      this.needwifi,
      this.needcameraimg,
      this.checkgps,
      this.checkqrcode,
      this.checkwifi});

  Location.fromJson(Map<String, dynamic> json) {
    locationid = json['locationid'];
    locationcaption = json['locationcaption'];
    range = json['range'];
    needgps = json['needgps'];
    needqrcode = json['needqrcode'];
    needwifi = json['needwifi'];
    needcameraimg = json['needcameraimg'];
    checkgps = json['checkgps'];
    checkqrcode = json['checkqrcode'];
    checkwifi = json['checkwifi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['locationid'] = locationid;
    data['locationcaption'] = locationcaption;
    data['range'] = range;
    data['needgps'] = needgps;
    data['needqrcode'] = needqrcode;
    data['needwifi'] = needwifi;
    data['needcameraimg'] = needcameraimg;
    data['checkgps'] = checkgps;
    data['checkqrcode'] = checkqrcode;
    data['checkwifi'] = checkwifi;
    return data;
  }
}
