import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';

void main() {
  test('the diff request declares this build contract version', () {
    final dto = GetResourceDiffRequestDto(
      appVersion: '1.8.0',
      currentVersion: 120,
      contractVersion: appResourceContractVersion.value,
    );

    final json = dto.toJson();

    expect(json['contractVersion'], 2);
    expect(json['appVersion'], '1.8.0');
  });

  test('the default request contract version stays 1', () {
    const dto = GetResourceDiffRequestDto(appVersion: '1.8.0', currentVersion: 120);

    expect(dto.toJson()['contractVersion'], 1);
  });
}
