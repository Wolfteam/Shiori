import 'dart:math';

class FormatUtils {
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    //Decimal, to match the suffixes above and the figures the api, the OS and the stores report.
    //Dividing by 1024 here labelled mebibytes as MB, understating a 152,526,964 byte archive as
    //145.46 MB
    const int unit = 1000;
    final int i = (log(bytes) / log(unit)).floor();
    return '${(bytes / pow(unit, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
