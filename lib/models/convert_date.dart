import 'package:intl/intl.dart';

class ConvertDate {
  static String? dateConvert;
  final String date;
  ConvertDate(this.date) {
    List<String> dateConvertList = date.substring(0, 10).split('-');
    dateConvert = List.from(dateConvertList.reversed).join('-');
  }
  getDate() {
    return dateConvert;
  }
}

String parseDate(String timeString) {
  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(timeString));
  } on FormatException {
    return '';
  }
}
