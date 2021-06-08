import 'package:darq/darq.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/game_code_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

const _wikiPage = 'https://genshin-impact.fandom.com/wiki/Promotional_Codes';

class GameCodeServiceImpl implements GameCodeService {
  final quantityRegex = RegExp(r'\d+', caseSensitive: false);
  final LoggingService _logger;
  final GenshinService _genshinService;

  GameCodeServiceImpl(this._logger, this._genshinService);

  @override
  Future<List<GameCodeModel>> getAllGameCodes() async {
    final items = <GameCodeModel>[];
    try {
      final response = await http.Client().get(Uri.parse(_wikiPage));
      if (response.statusCode != 200) {
        return items;
      }

      final document = parse(response.body);
      final tables = document.getElementsByTagName('table');
      if (tables.isEmpty) {
        _logger.warning(runtimeType, 'No table was found on the wiki page');
        return items;
      }

      final rows = tables.first.getElementsByTagName('tr');
      for (final row in rows) {
        final cells = row.getElementsByTagName('td');
        if (cells.isEmpty) {
          continue;
        }

        final region = _getRegion(cells[1].innerHtml);
        final code = cells.first.text.trim().split('[').first.trim();
        if (code.split(' ').length > 1) {
          continue;
        }

        final isExpired = cells[3].attributes.values.any((val) => val.contains('background-color:#F99'));
        DateTime discoveredOn;
        DateTime expiredOn;
        for (final node in cells[3].nodes) {
          final nodeText = node.text.replaceAll('\n', '').trim();

          if (nodeText.contains('Discovered')) {
            final x = nodeText.split(' ').last;
            discoveredOn = DateTime.parse(x.split(' ').first);
          }

          if (nodeText.contains('Expired')) {
            final y = nodeText.replaceAll('Expired', '').trim();
            if (y.isNotEmpty) {
              expiredOn = DateTime.parse(y.split(' ').first);
            }
          }

          if (nodeText.contains('Valid') && !nodeText.contains('indefinite')) {
            final z = nodeText.split(' ').last;
            expiredOn = DateTime.parse(z.split(' ').first);
          }
        }

        final rewards = _parseRewards(cells[2].nodes);
        items.add(GameCodeModel(
          code: code,
          expiredOn: expiredOn,
          isExpired: isExpired,
          isUsed: false,
          rewards: rewards,
          discoveredOn: discoveredOn,
          region: region,
        ));
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error occurred', e, s);
    }

    return items;
  }

  List<ItemAscensionMaterialModel> _parseRewards(NodeList cellNodes) {
    final rewards = <ItemAscensionMaterialModel>[];
    for (var i = 0; i < cellNodes.length; i++) {
      try {
        final node = cellNodes[i];
        if (node.text.trim().isEmpty) {
          continue;
        }

        final wikiName = node.text.trim();
        final quantityString = cellNodes[i + 1].text.trim().replaceAll('\n', '').replaceAll(',', '');
        final quantity = int.parse(quantityRegex.allMatches(quantityString).first.group(0));
        final type = _getMaterialType(wikiName);
        final image = _getMaterialImage(wikiName, type);
        rewards.add(ItemAscensionMaterialModel(quantity: quantity, materialType: type, image: image));
      } catch (e, s) {
        _logger.error(runtimeType, 'Unknown error parsing rewards', e, s);
      }

      i++;
    }
    return rewards;
  }

  MaterialType _getMaterialType(String wikiName) {
    switch (wikiName) {
      case 'Primogem':
      case 'Mora':
        return MaterialType.currency;
      case 'Mystic Enhancement Ore':
        return MaterialType.expWeapon;
      case "Hero's Wit":
      case "Adventurer's Experience":
        return MaterialType.expCharacter;
      default:
        final msg = 'The provided material wiki name = $wikiName is not mapped';
        _logger.error(runtimeType, msg);
        throw Exception(msg);
    }
  }

  String _getMaterialImage(String wikiName, MaterialType type) {
    final relatedMaterials = _genshinService.getMaterials(type);

    final map = <String, int>{};
    for (final material in relatedMaterials) {
      var matches = 0;
      final imageWithoutExt = material.image.substring(0, material.image.indexOf('.'));
      final characters = wikiName.split('');
      for (final char in characters) {
        if (imageWithoutExt.contains(char)) {
          matches++;
        }
      }
      map.putIfAbsent(material.image, () => matches);
    }

    return map.entries.orderBy((el) => el.value).last.key;
  }

  AppServerResetTimeType _getRegion(String wikiServer) {
    switch (wikiServer?.toLowerCase()?.trim()) {
      case 'europe':
        return AppServerResetTimeType.europe;
      case 'america':
        return AppServerResetTimeType.northAmerica;
      case 'asia':
      case 'china':
        return AppServerResetTimeType.asia;
      default:
        return null;
    }
  }
}
