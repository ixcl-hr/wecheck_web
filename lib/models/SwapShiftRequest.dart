import 'package:intl/intl.dart';
import '../constants/config.dart';

class SwapShiftRequestModel {
  bool? flag;
  String? message;
  List<SwapShiftRequest> objectresult = [];

  SwapShiftRequestModel({this.flag, this.message, required this.objectresult});

  SwapShiftRequestModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(SwapShiftRequest.fromJson(v));
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

class SwapShiftRequest {
  int? emp_workshift_id;
  int? workshift_id;
  String? start_date;
  String? end_date;
  int? approve_id;
  int? status_id;
  String? employee_code;
  String? employee_name;
  String? workshift_name;
  String? approver_name;
  String? status_name;
  String? remark;

  bool? hasRemark;
  DateTime? startdate;
  DateTime? enddate;

  SwapShiftRequest(
      {this.emp_workshift_id,
      this.workshift_id,
      this.start_date,
      this.end_date,
      this.approve_id,
      this.status_id,
      this.employee_code,
      this.employee_name,
      this.workshift_name,
      this.approver_name,
      this.status_name,
      this.remark}) {
    hasRemark = remark != null && remark.toString().isNotEmpty;
    startdate = getDate(dateStr: start_date);
    enddate = getDate(dateStr: end_date);
  }

  SwapShiftRequest.fromJson(Map<String, dynamic> json) {
    emp_workshift_id = json['emp_workshift_id'];
    workshift_id = json['workshift_id'];
    start_date = json['start_date'];
    end_date = json['end_date'];
    approve_id = json['approve_id'];
    status_id = json['status_id'];
    employee_code = json['employee_code'];
    employee_name = json['employee_name'];
    workshift_name = json['workshift_name'];
    approver_name = json['approver_name'];
    status_name = json['status_name'];
    remark = json['remark'];

    hasRemark = remark != null && remark.toString().isNotEmpty;
    startdate = getDate(dateStr: start_date);
    enddate = getDate(dateStr: end_date);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emp_workshift_id'] = emp_workshift_id;
    data['workshift_id'] = workshift_id;
    data['start_date'] = start_date;
    data['end_date'] = end_date;
    data['approve_id'] = approve_id;
    data['status_id'] = status_id;
    data['employee_code'] = employee_code;
    data['employee_name'] = employee_name;
    data['workshift_name'] = workshift_name;
    data['approver_name'] = approver_name;
    data['status_name'] = status_name;
    data['remark'] = remark;
    return data;
  }

  String getStartdate({String? pattern}) {
    pattern = pattern ?? dateFormat;
    return start_date == null
        ? ""
        : DateFormat(pattern).format(startdate as DateTime);
  }

  String getEnddate({String? pattern}) {
    //'yyyy-MM-ddTHH:mm:ss'}) {
    pattern = pattern ?? dateFormat;
    return end_date == null
        ? ""
        : DateFormat(pattern).format(enddate as DateTime);
  }

  DateTime? getDate({String? dateStr}) {
    return dateStr == null
        ? null
        : (DateFormat('yyyy-MM-dd').parse(dateStr.toString().substring(0, 11)));
  }
}
