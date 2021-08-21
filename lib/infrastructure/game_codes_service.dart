import 'package:darq/darq.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/game_code_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
        final gameCode = _parseGameCode(row);
        if (gameCode == null) {
          continue;
        }

        items.add(gameCode);
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error occurred', e, s);
    }

    return items;
  }

  GameCodeModel? _parseGameCode(Element row) {
    try {
      final cells = row.getElementsByTagName('td');
      if (cells.isEmpty) {
        return null;
      }

      final region = _getRegion(cells[1].innerHtml);
      final code = cells.first.text.trim().split('[').first.trim();
      if (code.split(' ').length > 1) {
        return null;
      }

      const redColorA = 'background-color:#F99';
      const redColorB = 'background-color:rgb(255,153,153,0.5)';
      final isExpired = cells[3].attributes.values.any((val) => val.contains(redColorA) || val.contains(redColorB) || val.contains('expired'));

      DateTime? discoveredOn;
      DateTime? expiredOn;
      for (final node in cells[3].nodes) {
        final nodeText = node.text!.replaceAll('\n', '').trim();

        discoveredOn ??= _parseDate(nodeText, discovered: true);
        expiredOn ??= _parseDate(nodeText, expired: true);
      }

      final rewards = _parseRewards(cells[2].nodes);
      return GameCodeModel(
        code: code,
        expiredOn: expiredOn,
        isExpired: isExpired,
        isUsed: false,
        rewards: rewards,
        discoveredOn: discoveredOn,
        region: region,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_parseGameCode: Unknown error occurred', e, s);
    }
    return null;
  }

  List<ItemAscensionMaterialModel> _parseRewards(NodeList cellNodes) {
    final rewards = <ItemAscensionMaterialModel>[];
    for (var i = 0; i < cellNodes.length; i++) {
      try {
        final node = cellNodes[i];
        if (node.text!.trim().isEmpty) {
          continue;
        }

        final wikiName = node.text!.trim();
        final type = _getMaterialType(wikiName);
        if (type == null) {
          continue;
        }

        final quantityString = cellNodes[i + 1].text!.trim().replaceAll('\n', '').replaceAll(',', '');
        final quantity = int.parse(quantityRegex.allMatches(quantityString).first.group(0)!);
        final image = _getMaterialImage(wikiName, type);
        rewards.add(ItemAscensionMaterialModel(quantity: quantity, materialType: type, image: image));
      } catch (e, s) {
        _logger.error(runtimeType, '_parseRewards: Unknown error', e, s);
      }

      i++;
    }
    return rewards;
  }

  MaterialType? _getMaterialType(String wikiName) {
    switch (wikiName) {
      case 'Primogem':
      case 'Mora':
        return MaterialType.currency;
      case 'Mystic Enhancement Ore':
      case 'Fine Enhancement Ore':
        return MaterialType.expWeapon;
      case "Hero's Wit":
      case "Adventurer's Experience":
        return MaterialType.expCharacter;
      default:
        return null;
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

  AppServerResetTimeType? _getRegion(String? wikiServer) {
    switch (wikiServer?.toLowerCase().trim()) {
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

  DateTime? _parseDate(
    String nodeText, {
    bool discovered = false,
    bool expired = false,
  }) {
    try {
      //Since the page is in english, we must use english, otherwise date format will try to use the system's one
      final locale = languagesMap.entries.firstWhere((el) => el.key == AppLanguageType.english).value;
      final format = DateFormat('MMMM d, yyyy', '${locale.code}_${locale.countryCode}');
      //Discovered: June 8, 2021
      if (discovered && nodeText.contains('Discovered')) {
        final x = nodeText.replaceAll('Discovered', '').replaceAll(':', '').trim();
        return format.parse(x);
      }

      //Expired June 9, 2021
      if (expired && nodeText.contains('Expired')) {
        final y = nodeText.replaceAll('Expired', '').replaceAll(':', '').trim();
        if (y.isNotEmpty) {
          return format.parse(y);
        }
      }

      //Valid: June 9, 2021 or Valid until July 21, 2021
      if (expired && nodeText.contains('Valid') && !nodeText.contains('indefinite')) {
        final z = nodeText.replaceAll('Valid', '').replaceAll('until', '').replaceAll(':', '').trim();
        return format.parse(z);
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error parsing date. NodeText = $nodeText - Discovered = $discovered - Expired = $expired', e, s);
    }

    return null;
  }
}
