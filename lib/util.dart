import 'package:intl/intl.dart';

String printDuration(Duration duration) {
  //Source : https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String toIndonesianDateTime(DateTime time) {
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  return formatter.format(time);
}
