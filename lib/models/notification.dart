class NotificationModel {
  Map<String, dynamic> json = <String, dynamic>{};
  bool? flag;
  String? message;
  List<NotificationObject> objectresult = [];

  NotificationModel(
      {required this.json,
      this.flag,
      this.message,
      required this.objectresult});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    List<NotificationObject> objRes = [];
    if (json['objectresult'] != null) {
      json['objectresult'].forEach((v) {
        objRes.add(NotificationObject.fromJson(v));
        // objRes.add(NotificationObject.fromJson(v));
        // objRes.add(NotificationObject.fromJson(v));
        // objRes.add(NotificationObject.fromJson(v));
      });
    }
    return NotificationModel(
      json: json,
      flag: json['flag'],
      message: json['message'],
      objectresult: objRes,
    );
  }
}

class NotificationObject {
  Map<String, dynamic>? json;
  String? type;
  String? dateTime;
  String? employeeCode;
  String? employeeName;
  String? startdate;
  String? starttime;
  String? oldLocationName;
  String? oldIsactive;
  String? enddate;
  String? endtime;
  String? newLocationName;
  String? newIsactive;
  String? isRead;
  String? statusName;

  NotificationObject({
    this.json,
    this.type,
    this.dateTime,
    this.employeeCode,
    this.employeeName,
    this.startdate,
    this.starttime,
    this.oldLocationName,
    this.oldIsactive,
    this.enddate,
    this.endtime,
    this.newLocationName,
    this.newIsactive,
    this.isRead,
    this.statusName,
  });

  factory NotificationObject.fromJson(Map<String, dynamic> json) {
    return NotificationObject(
      json: json,
      type: json['notificationtype'],
      dateTime: json['notificationdatetime'],
      employeeCode: json['employeecode'],
      employeeName: json['employeename'],
      startdate: json['startdate'],
      starttime: json['starttime'],
      oldLocationName: json['oldlocationname'],
      oldIsactive: json['oldisactive'],
      enddate: json['enddate'],
      endtime: json['endtime'],
      newLocationName: json['newlocationname'],
      newIsactive: json['newisactive'],
      isRead: json['isread'],
      statusName: json['statusname'],
    );
  }
}
