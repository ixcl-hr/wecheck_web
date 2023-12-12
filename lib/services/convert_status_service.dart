import 'package:wecheck/services/util_service.dart';

class ConvertStatus {
  static String statusConvert = "";
  final int? statusid;
  ConvertStatus({this.statusid}) {
    if (statusid == 6000001) {
      statusConvert = 'รออนุมัติ';
    } else if (statusid == 6000002) {
      statusConvert = 'อนุมัติ';
    } else if (statusid == 6000003) {
      statusConvert = 'ไม่อนุมัติ';
    }
  }
  getStatusid() {
    return statusConvert;
  }
}

class ConvertAbsentStatus {
  String statusConvert = "";
  final int? statusid;

  ConvertAbsentStatus({this.statusid}) {
    statusConvert = UtilService.getStatusName(this.statusid);
  }
  getStatusid() {
    return statusConvert;
  }
}
