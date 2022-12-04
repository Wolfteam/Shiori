import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/settings/widgets/settings_card_content.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CreditsSettingsCard extends StatelessWidget {
  final Map<AppLanguageType, List<String>> _translators = {
    AppLanguageType.simplifiedChinese: ['2O48#9733'],
    AppLanguageType.russian: ['SipTik#1171', 'KKTS#8567', 'KlimeLime#7577', 'Avantel#8880', 'чебилин#5968', 'Anixty#3279'],
    AppLanguageType.portuguese: ['Brunoff#0261', 'DanPS#4336', 'JJlago#0406'],
    AppLanguageType.italian: ['Reniel [Skidex ツ]#7982', 'Septenebris#7356'],
    AppLanguageType.japanese: ['Ruri#3080'],
    AppLanguageType.vietnamese: ['Ren Toky#5263'],
    AppLanguageType.indonesian: ['Arctara#7162'],
    AppLanguageType.deutsch: ['Marik#0823', 'yourGeneralGenshinWeeb#1460'],
    AppLanguageType.french: ['GuadoDex#3357', 'therealcorwin', 'Herellya#8181', 'Muden#2742'],
    AppLanguageType.ukrainian: ['VALLER1Y#4726'],
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SettingsCardContent(
      title: s.credits,
      subTitle: s.translators,
      icon: const Icon(Icons.info_outline),
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        margin: Styles.edgeInsetHorizontal16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              s.creditsTranslatorsMsg,
              textAlign: TextAlign.center,
            ),
            ..._translators.entries.map((kvp) => _TranslatorsRow(language: kvp.key, translators: kvp.value))
          ],
        ),
      ),
    );
  }
}

class _TranslatorsRow extends StatelessWidget {
  final AppLanguageType language;
  final List<String> translators;
  final double fontSize;

  const _TranslatorsRow({
    required this.language,
    required this.translators,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    final left = <String>[];
    final right = <String>[];
    if (translators.length > 2) {
      final int half = (translators.length / 2).round();
      left.addAll(translators.take(half));
      right.addAll(translators.skip(half));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(
            s.translateAppLanguageType(language),
            style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (translators.length <= 2)
          BulletList(items: translators, fontSize: fontSize)
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BulletList(items: left, fontSize: fontSize)),
              Expanded(child: BulletList(items: right, fontSize: fontSize)),
            ],
          ),
      ],
    );
  }
}
