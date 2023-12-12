class AppInfo {
  String? app_name;
  String? app_version;
  int? build_number;

  AppInfo({this.app_name, this.app_version, this.build_number});

  AppInfo.fromJson(Map<String, dynamic> json) {
    app_name = json['app_name'];
    app_version = json['app_version'];
    build_number = json['build_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['app_name'] = app_name;
    data['app_version'] = app_version;
    data['build_number'] = build_number;

    return data;
  }
}
