import 'package:intl/intl.dart';

class ConvertTime {
  static String timeConvert = "";
  final String time;
  ConvertTime(this.time) {
    timeConvert = time.substring(11, 16);
  }
  getTime() {
    return timeConvert;
  }
}

String parseTime(String timeString) {
  try {
    return DateFormat('HH:mm').format(DateTime.parse(timeString));
  } on FormatException {
    return '';
  }
}
