import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/utils/date_utils.dart';

import '../common.dart';

void main() {
  final languages = AppLanguageType.values.toList();
  group('Get character birthday', () {
    test("check Bennet's birthday not using current year", () {
      for (final lang in languages) {
        final service = getLocaleService(lang);
        final birthday = service.getCharBirthDate('02/29');
        expect(birthday.day, equals(29));
        expect(birthday.month, equals(DateTime.february));
      }
    });

    test("check Bennet's birthday using current year", () {
      for (final lang in languages) {
        final service = getLocaleService(lang);
        final birthday = service.getCharBirthDate('02/29', useCurrentYear: true);
        final lastDayOfFebruary = DateUtils.getLastDayOfMonth(DateTime.february);
        expect(birthday.day, equals(lastDayOfFebruary));
        expect(birthday.month, equals(DateTime.february));
      }
    });
  });
}
