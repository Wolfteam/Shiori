import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/utils/format_utils.dart';

void main() {
  group('formatBytes', () {
    test('uses decimal units so the value matches the byte count', () {
      //The real full archive. Dividing by 1024 reported 145.46 MB for this, which does not match
      //the number the api returns nor what the OS and the stores report
      expect(FormatUtils.formatBytes(152526964), '152.53 MB');
    });

    test('formats each magnitude', () {
      expect(FormatUtils.formatBytes(999), '999.00 B');
      expect(FormatUtils.formatBytes(1000), '1.00 KB');
      expect(FormatUtils.formatBytes(1000000), '1.00 MB');
      expect(FormatUtils.formatBytes(1000000000), '1.00 GB');
    });

    test('honours the decimals argument', () {
      expect(FormatUtils.formatBytes(152526964, decimals: 0), '153 MB');
      expect(FormatUtils.formatBytes(1500, decimals: 1), '1.5 KB');
    });

    test('returns zero for non positive values', () {
      expect(FormatUtils.formatBytes(0), '0 B');
      expect(FormatUtils.formatBytes(-1), '0 B');
    });
  });
}
