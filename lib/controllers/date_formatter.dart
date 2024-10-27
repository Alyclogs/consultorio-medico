import 'package:intl/intl.dart';

class DateFormatter {
  DateTime formatDateString(String dateString) {
    DateFormat inputFormat = DateFormat("dd/MM/yyyy");
    return inputFormat.parse(dateString);
  }

  String formatStringDate(DateTime date) {
    DateFormat inputFormat = DateFormat("dd/MM/yyyy");
    return inputFormat.format(date);
  }
}