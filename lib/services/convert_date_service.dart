import 'package:intl/intl.dart';

class ConvertDate {
  static String dateConvert = "";
  final String date;
  ConvertDate(this.date) {
    if (date.isNotEmpty) {
      List<String> dateConvertList = date.substring(0, 10).split('-');
      dateConvert = List.from(dateConvertList.reversed).join('-');
    }
  }
  getDate() {
    return dateConvert;
  }
}

String parseDate(String timeString) {
  try {
    if (timeString.isNotEmpty) {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(timeString));
    } else {
      return '';
    }
  } on FormatException {
    return '';
  }
}
