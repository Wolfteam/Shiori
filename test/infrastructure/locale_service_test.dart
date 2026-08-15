import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../common.dart';

void main() {
  final languages = AppLanguageType.values.toList();
  test("check Bennet's birthday using current year", () {
    for (final lang in languages) {
      final service = getLocaleService(lang);
      final birthday = service.getCharBirthDate('02/29');
      expect(
        birthday.month,
        equals(DateTime.february),
        reason: 'Parsed birthday month must be February for input 02/29, got ${birthday.month} (lang=${lang.name})',
      );
      expect(
        birthday.day,
        29,
        reason: 'Parsed birthday day must be 29 for input 02/29, got ${birthday.day} (lang=${lang.name})',
      );
    }
  });
}
