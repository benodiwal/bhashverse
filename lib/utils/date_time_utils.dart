class DateTImeUtils {
  String getTimeFromMilliseconds({required int timeInMillisecond}) {
    int sec = (timeInMillisecond / 1000).truncate() % 60;
    int min = ((timeInMillisecond / 1000).truncate() / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }
}
