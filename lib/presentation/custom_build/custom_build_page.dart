import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/artifacts/artifacts_page.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';
import 'package:shiori/presentation/shared/dialogs/select_artifact_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/select_stat_type_dialog.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

class CustomBuildPage extends StatelessWidget {
  final int? itemKey;

  bool get newBuild => itemKey != null;

  const CustomBuildPage({
    Key? key,
    this.itemKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    //TODO: SHOW THE TALENTS AND CONSTELLATIONS LIKE THIS
    //https://genshin-impact-card-generator.herokuapp.com/
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider(
      create: (ctx) => Injection.customBuildBloc..add(CustomBuildEvent.load(key: itemKey)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(newBuild ? 'Add' : s.edit),
          actions: [
            IconButton(
              onPressed: () {},
              splashRadius: Styles.mediumButtonSplashRadius,
              icon: const Icon(Icons.save),
            ),
            IconButton(
              onPressed: () {},
              splashRadius: Styles.mediumButtonSplashRadius,
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () {},
              splashRadius: Styles.mediumButtonSplashRadius,
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: BlocBuilder<CustomBuildBloc, CustomBuildState>(
          builder: (ctx, state) => state.maybeMap(
            loaded: (state) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MainCard(
                    title: state.title.isNullEmptyOrWhitespace ? s.na : state.title,
                    type: state.type,
                    subType: state.subType,
                    showOnCharacterDetail: state.showOnCharacterDetail,
                    character: state.character,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Weapons(
                          weapons: state.weapons,
                          color: state.character.elementType.getElementColorFromContext(context),
                        ),
                      ),
                      Expanded(
                        child: _Artifacts(
                          artifacts: state.artifacts,
                          color: state.character.elementType.getElementColorFromContext(context),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  final String title;
  final CharacterRoleType type;
  final CharacterRoleSubType subType;
  final bool showOnCharacterDetail;
  final CharacterCardModel character;

  const _MainCard({
    Key? key,
    required this.title,
    required this.type,
    required this.subType,
    required this.showOnCharacterDetail,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      color: character.elementType.getElementColorFromContext(context),
      child: Row(
        children: [
          Expanded(
            flex: 40,
            child: CharacterStackImage(
              name: character.name,
              image: character.image,
              rarity: character.stars,
              onTap: () => _openCharacterPage(context),
            ),
          ),
          const Spacer(flex: 3),
          Expanded(
            flex: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      splashRadius: Styles.smallButtonSplashRadius,
                      icon: const Icon(Icons.edit),
                    )
                  ],
                ),
                DropdownButtonWithTitle<CharacterRoleType>(
                  margin: EdgeInsets.zero,
                  title: s.role,
                  currentValue: type,
                  items: EnumUtils.getTranslatedAndSortedEnum<CharacterRoleType>(
                    CharacterRoleType.values,
                    (val, _) => s.translateCharacterRoleType(val),
                  ),
                  onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.roleChanged(newValue: v)),
                ),
                DropdownButtonWithTitle<CharacterRoleSubType>(
                  margin: EdgeInsets.zero,
                  title: 'Sub type',
                  currentValue: subType,
                  items: EnumUtils.getTranslatedAndSortedEnum<CharacterRoleSubType>(
                    CharacterRoleSubType.values,
                    (val, _) => s.translateCharacterRoleSubType(val),
                  ),
                  onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.subRoleChanged(newValue: v)),
                ),
                SwitchListTile(
                  activeColor: theme.colorScheme.secondary,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Show on character detail'),
                  value: showOnCharacterDetail,
                  onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.showOnCharacterDetailChanged(newValue: v)),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Future<void> _openCharacterPage(BuildContext context) async {
    //TODO: EXCLUDE UPCOMING CHARACTERS ?
    final bloc = context.read<CustomBuildBloc>();
    final selectedKey = await CharactersPage.forSelection(context, excludeKeys: [character.key]);
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }

    bloc.add(CustomBuildEvent.characterChanged(newKey: selectedKey!));
  }
}

class _Weapons extends StatelessWidget {
  final List<WeaponCardModel> weapons;
  final Color color;

  const _Weapons({
    Key? key,
    required this.weapons,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: Styles.edgeInsetVertical10,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: color,
            border: Border(top: BorderSide(color: Colors.white)),
          ),
          child: Text(
            s.weapons,
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...weapons
                .map(
                  (e) => WeaponCard.withoutDetails(
                    keyName: e.key,
                    name: e.name,
                    rarity: e.rarity,
                    image: e.image,
                    isComingSoon: e.isComingSoon,
                    imgHeight: 60,
                    imgWidth: 70,
                  ),
                )
                .toList(),
            IconButton(
              color: theme.colorScheme.secondary,
              iconSize: 60,
              splashRadius: Styles.mediumBigButtonSplashRadius,
              icon: const Icon(Icons.add),
              onPressed: () => _openWeaponsPage(context),
            )
          ],
        ),
      ],
    );
  }

  Future<void> _openWeaponsPage(BuildContext context) async {
    final bloc = context.read<CustomBuildBloc>();
    final selectedKey = await WeaponsPage.forSelection(context, excludeKeys: weapons.map((e) => e.key).toList());
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }
    bloc.add(CustomBuildEvent.addWeapon(key: selectedKey!));
  }
}

class _Artifacts extends StatelessWidget {
  final List<ArtifactCardModel> artifacts;
  final Color color;

  const _Artifacts({
    Key? key,
    required this.artifacts,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: Styles.edgeInsetVertical10,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: color,
            border: Border(top: BorderSide(color: Colors.white)),
          ),
          child: Text(
            s.artifacts,
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...artifacts
                .map(
                  (e) => ArtifactCard.withoutDetails(
                    keyName: e.key,
                    name: e.name,
                    image: e.image,
                    rarity: e.rarity,
                  ),
                )
                .toList(),
            if (artifacts.length < ArtifactType.values.length)
              IconButton(
                color: theme.colorScheme.secondary,
                iconSize: 60,
                splashRadius: Styles.mediumBigButtonSplashRadius,
                icon: const Icon(Icons.add),
                onPressed: () => _addArtifact(context),
              ),
          ],
        )
      ],
    );
  }

  Future<void> _addArtifact(BuildContext context) async {
    final selectedType = await showDialog<ArtifactType>(context: context, builder: (ctx) => const SelectArtifactTypeDialog());
    if (selectedType == null) {
      return;
    }

    StatType? statType;
    switch (selectedType) {
      case ArtifactType.flower:
        statType = StatType.hp;
        break;
      case ArtifactType.plume:
        statType = StatType.atk;
        break;
      default:
        statType = await showDialog<StatType>(
          context: context,
          builder: (ctx) => SelectStatTypeDialog(
            values: getArtifactPossibleMainStats(selectedType),
          ),
        );
        break;
    }

    if (statType == null) {
      return;
    }

    await _openArtifactsPage(context, selectedType);
  }

  Future<void> _openArtifactsPage(BuildContext context, ArtifactType type) async {
    //TODO: REMOVE THE CROWNS AND MAYBE ONLY SHOW THE SPECIFIC TYPE
    final bloc = context.read<CustomBuildBloc>();
    final selectedKey = await ArtifactsPage.forSelection(context, type: type);
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }
    bloc.add(CustomBuildEvent.addArtifact(key: selectedKey!, type: type));
  }
}
