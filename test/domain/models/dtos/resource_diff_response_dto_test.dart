import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/models/dtos.dart';

void main() {
  group('ResourceDiffResponseDto', () {
    test('parses a contract 2 delta payload', () {
      final json = {
        'currentResourceVersion': 100,
        'targetResourceVersion': 122,
        'downloadTotalSize': 30,
        'jsonFileKeyName': null,
        'keyNames': <String>[],
        'mode': 2,
        'archives': [
          {
            'version': 121,
            'keyName': 'versions/v121/delta.zip',
            'sizeInBytes': 10,
            'sha256': 'aaa',
            'contractVersion': 2,
          },
          {
            'version': 122,
            'keyName': 'versions/v122/delta.zip',
            'sizeInBytes': 20,
            'sha256': 'bbb',
            'contractVersion': 2,
          },
        ],
      };

      final dto = ResourceDiffResponseDto.fromJson(json);

      expect(dto.mode, 2);
      expect(dto.archives.length, 2);
      expect(dto.archives.first.keyName, 'versions/v121/delta.zip');
      expect(dto.archives.last.sha256, 'bbb');
    });

    test('parses a legacy payload from a backend that predates archives', () {
      final json = {
        'currentResourceVersion': 100,
        'targetResourceVersion': 122,
        'downloadTotalSize': 500,
        'jsonFileKeyName': null,
        'keyNames': ['versions/v122/db/characters.1.json'],
      };

      final dto = ResourceDiffResponseDto.fromJson(json);

      expect(dto.mode, 1);
      expect(dto.archives, isEmpty);
      expect(dto.keyNames.length, 1);
    });
  });
}
