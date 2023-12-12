class GetAbsentQuotaModel {
  bool? flag;
  String? message;
  List<AbsentQuota> objectresult = [];

  GetAbsentQuotaModel({this.flag, this.message, required this.objectresult});

  GetAbsentQuotaModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      // ignore: deprecated_member_use
      // objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(AbsentQuota.fromJson(v));
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

class AbsentQuota {
  int? absenttypeid;
  String? absenttypename;
  double? absentspent;
  double? absentquota;

  AbsentQuota(
      {this.absenttypeid,
      this.absenttypename,
      this.absentspent,
      this.absentquota});

  AbsentQuota.fromJson(Map<String, dynamic> json) {
    absenttypeid = json['absenttypeid'];
    absenttypename = json['absenttypename'];
    absentspent = json['absentspent'];
    absentquota = json['absentquota'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['absenttypeid'] = absenttypeid;
    data['absenttypename'] = absenttypename;
    data['absentspent'] = absentspent;
    data['absentquota'] = absentquota;
    return data;
  }
}
