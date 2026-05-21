import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../common.dart';

void main() {
  final languages = AppLanguageType.values.toList();
  test("check Bennet's birthday using current year", () {
    for (final lang in languages) {
      final service = getLocaleService(lang);
      final birthday = service.getCharBirthDate('02/29');
      expect(birthday.month, equals(DateTime.february), reason: 'Should equal expected value (property=month, lang=${lang.name})');
      expect(birthday.day, 29, reason: 'Should match expected value (property=day, expected=29, lang=${lang.name})');
    }
  });
}
