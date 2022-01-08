import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:screenshot/screenshot.dart';
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
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

const double _maxItemImageWidth = 130;

class CustomBuildPage extends StatelessWidget {
  final int? itemKey;

  bool get newBuild => itemKey == null;

  const CustomBuildPage({
    Key? key,
    this.itemKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: SHOW THE TALENTS AND CONSTELLATIONS LIKE THIS
    //https://genshin-impact-card-generator.herokuapp.com/
    return BlocProvider(
      create: (ctx) => Injection.customBuildBloc..add(CustomBuildEvent.load(key: itemKey)),
      child: _Page(
        newBuild: newBuild,
      ),
    );
  }
}

class _Page extends StatefulWidget {
  final bool newBuild;

  const _Page({Key? key, required this.newBuild}) : super(key: key);

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: _AppBar(newBuild: widget.newBuild, screenshotController: _screenshotController),
      body: BlocBuilder<CustomBuildBloc, CustomBuildState>(
        builder: (ctx, state) => state.maybeMap(
          loaded: (state) => SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 10),
            child: Screenshot(
              controller: _screenshotController,
              child: OrientationLayoutBuilder(
                portrait: (context) => _PortraitLayout(
                  title: state.title.isNullEmptyOrWhitespace ? s.dps : state.title,
                  roleType: state.type,
                  roleSubType: state.subType,
                  showOnCharacterDetail: state.showOnCharacterDetail,
                  character: state.character,
                  weapons: state.weapons,
                  artifacts: state.artifacts,
                ),
                landscape: (context) => width > 700
                    ? _LandscapeLayout(
                        title: state.title.isNullEmptyOrWhitespace ? s.dps : state.title,
                        roleType: state.type,
                        roleSubType: state.subType,
                        showOnCharacterDetail: state.showOnCharacterDetail,
                        character: state.character,
                        weapons: state.weapons,
                        artifacts: state.artifacts,
                      )
                    : _PortraitLayout(
                        title: state.title.isNullEmptyOrWhitespace ? s.dps : state.title,
                        roleType: state.type,
                        roleSubType: state.subType,
                        showOnCharacterDetail: state.showOnCharacterDetail,
                        character: state.character,
                        weapons: state.weapons,
                        artifacts: state.artifacts,
                      ),
              ),
            ),
          ),
          orElse: () => const Loading(useScaffold: false),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool newBuild;
  final ScreenshotController screenshotController;

  const _AppBar({
    Key? key,
    required this.newBuild,
    required this.screenshotController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AppBar(
      title: Text(newBuild ? 'Add' : s.edit),
      actions: [
        IconButton(
          onPressed: () {},
          splashRadius: Styles.mediumButtonSplashRadius,
          icon: const Icon(Icons.save),
        ),
        if (!newBuild)
          IconButton(
            onPressed: () {},
            splashRadius: Styles.mediumButtonSplashRadius,
            icon: const Icon(Icons.delete),
          ),
        IconButton(
          onPressed: () => _takeScreenshot(context),
          splashRadius: Styles.mediumButtonSplashRadius,
          icon: const Icon(Icons.share),
        ),
      ],
    );
  }

  Future<void> _takeScreenshot(BuildContext context) async {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    // final bloc = context.read<TierListBloc>();
    try {
      if (!await Permission.storage.request().isGranted) {
        ToastUtils.showInfoToast(fToast, s.acceptToSaveImg);
        return;
      }

      final bytes = await screenshotController.capture(pixelRatio: 1.5);
      await ImageGallerySaver.saveImage(bytes!, quality: 100);
      ToastUtils.showSucceedToast(fToast, s.imgSavedSuccessfully);
      // bloc.add(const TierListEvent.screenshotTaken(succeed: true));
    } catch (e, trace) {
      ToastUtils.showErrorToast(fToast, s.unknownError);
      // bloc.add(TierListEvent.screenshotTaken(succeed: false, ex: e, trace: trace));
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PortraitLayout extends StatelessWidget {
  final String title;
  final CharacterRoleType roleType;
  final CharacterRoleSubType roleSubType;
  final bool showOnCharacterDetail;
  final CharacterCardModel character;
  final List<WeaponCardModel> weapons;
  final List<CustomBuildArtifactModel> artifacts;

  const _PortraitLayout({
    Key? key,
    required this.title,
    required this.roleType,
    required this.roleSubType,
    required this.showOnCharacterDetail,
    required this.character,
    required this.weapons,
    required this.artifacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MainCard(
          title: title,
          type: roleType,
          subType: roleSubType,
          showOnCharacterDetail: showOnCharacterDetail,
          character: character,
        ),
        ScreenTypeLayout.builder(
          desktop: (context) => _WeaponsAndArtifacts(
            elementType: character.elementType,
            weapons: weapons,
            artifacts: artifacts,
          ),
          tablet: (context) => _WeaponsAndArtifacts(
            elementType: character.elementType,
            weapons: weapons,
            artifacts: artifacts,
          ),
          mobile: (context) => _WeaponsAndArtifacts(
            useColumn: isPortrait,
            elementType: character.elementType,
            weapons: weapons,
            artifacts: artifacts,
          ),
        ),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final String title;
  final CharacterRoleType roleType;
  final CharacterRoleSubType roleSubType;
  final bool showOnCharacterDetail;
  final CharacterCardModel character;
  final List<WeaponCardModel> weapons;
  final List<CustomBuildArtifactModel> artifacts;

  const _LandscapeLayout({
    Key? key,
    required this.title,
    required this.roleType,
    required this.roleSubType,
    required this.showOnCharacterDetail,
    required this.character,
    required this.weapons,
    required this.artifacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 40,
          child: _MainCard(
            title: title,
            type: roleType,
            subType: roleSubType,
            showOnCharacterDetail: showOnCharacterDetail,
            character: character,
          ),
        ),
        Expanded(
          flex: 30,
          child: _Weapons(
            weapons: weapons,
            color: character.elementType.getElementColorFromContext(context),
          ),
        ),
        Expanded(
          flex: 30,
          child: _Artifacts(
            artifacts: artifacts,
            color: character.elementType.getElementColorFromContext(context),
          ),
        ),
      ],
    );
  }
}

class _WeaponsAndArtifacts extends StatelessWidget {
  final ElementType elementType;
  final List<WeaponCardModel> weapons;
  final List<CustomBuildArtifactModel> artifacts;
  final bool useColumn;

  const _WeaponsAndArtifacts({Key? key, required this.elementType, required this.weapons, required this.artifacts, this.useColumn = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useColumn) {
      return Column(
        children: [
          _Weapons(
            weapons: weapons,
            color: elementType.getElementColorFromContext(context),
          ),
          _Artifacts(
            artifacts: artifacts,
            color: elementType.getElementColorFromContext(context),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Weapons(
            weapons: weapons,
            color: elementType.getElementColorFromContext(context),
          ),
        ),
        Expanded(
          child: _Artifacts(
            artifacts: artifacts,
            color: elementType.getElementColorFromContext(context),
          ),
        ),
      ],
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    double imgHeight = height * (isPortrait ? 0.5 : 0.8);
    if (imgHeight > 700) {
      imgHeight = 700;
    }
    final flexA = width < 400 ? 55 : 60;
    final flexB = width < 400 ? 45 : 40;
    return Container(
      color: character.elementType.getElementColorFromContext(context),
      child: Row(
        children: [
          Expanded(
            flex: flexA,
            child: CharacterStackImage(
              name: character.name,
              image: character.image,
              rarity: character.stars,
              height: imgHeight,
              onTap: () => _openCharacterPage(context),
            ),
          ),
          Expanded(
            flex: flexB,
            child: Padding(
              padding: Styles.edgeInsetHorizontal5,
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
                      CharacterRoleType.values.where((el) => el != CharacterRoleType.na).toList(),
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
          ),
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
    //TODO: WEAPON REFINEMENTS
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: Styles.edgeInsetVertical10,
          // margin: const EdgeInsets.only(bottom: 10),
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
        ButtonBar(
          buttonPadding: EdgeInsets.zero,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              splashRadius: Styles.smallButtonSplashRadius,
              onPressed: () => _openWeaponsPage(context),
              icon: Icon(Icons.add),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              splashRadius: Styles.smallButtonSplashRadius,
              onPressed: () {},
              icon: Icon(Icons.clear_all),
            ),
          ],
        ),
        if (weapons.isEmpty) NothingFound(msg: 'Start by adding some weapons'),
        ...weapons
            .map(
              (e) => Row(
                children: [
                  SizedBox(
                    width: _maxItemImageWidth,
                    child: WeaponCard.withoutDetails(
                      keyName: e.key,
                      name: e.name,
                      rarity: e.rarity,
                      image: e.image,
                      isComingSoon: e.isComingSoon,
                      withShape: false,
                      imgWidth: 94,
                      imgHeight: 84,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: Styles.edgeInsetHorizontal16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Serpent Spine',
                            style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Base Atk: 41',
                            style: theme.textTheme.subtitle2!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            'Secondary Stat: 12.0 ATK%',
                            style: theme.textTheme.subtitle2!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    splashRadius: Styles.smallButtonSplashRadius,
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
            )
            .toList(),
        // Wrap(
        //   alignment: WrapAlignment.center,
        //   crossAxisAlignment: WrapCrossAlignment.center,
        //   children: [
        //     ...weapons
        //         .map(
        //           (e) => WeaponCard.withoutDetails(
        //             keyName: e.key,
        //             name: e.name,
        //             rarity: e.rarity,
        //             image: e.image,
        //             isComingSoon: e.isComingSoon,
        //             // imgHeight: 60,
        //             // imgWidth: 70,
        //           ),
        //         )
        //         .toList(),
        //     IconButton(
        //       color: theme.colorScheme.secondary,
        //       iconSize: 60,
        //       splashRadius: Styles.mediumBigButtonSplashRadius,
        //       icon: const Icon(Icons.add),
        //       onPressed: () => _openWeaponsPage(context),
        //     )
        //   ],
        // ),
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
  final List<CustomBuildArtifactModel> artifacts;
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
    final possibleSubStats = getArtifactPossibleSubStats();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: Styles.edgeInsetVertical10,
          // margin: const EdgeInsets.only(bottom: 10),
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
        ButtonBar(
          buttonPadding: EdgeInsets.zero,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              splashRadius: Styles.smallButtonSplashRadius,
              onPressed: artifacts.length < ArtifactType.values.length ? () => _addArtifact(context) : null,
              icon: Icon(Icons.add),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              splashRadius: Styles.smallButtonSplashRadius,
              onPressed: () {},
              icon: Icon(Icons.clear_all),
            ),
          ],
        ),
        if (artifacts.isEmpty) NothingFound(msg: 'Start by adding some artifacts'),
        ...artifacts.map(
          (e) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: _maxItemImageWidth,
                child: ArtifactCard.withoutDetails(
                  keyName: e.key,
                  name: s.translateStatTypeWithoutValue(e.statType),
                  image: e.image,
                  rarity: e.rarity,
                  withShape: false,
                  withTextOverflow: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: Styles.edgeInsetHorizontal16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s.translateArtifactType(e.type),
                        style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Archaic Petra',
                        style: theme.textTheme.subtitle1,
                      ),
                      // Text('Substats', style: theme.textTheme.subtitle2),
                      SubStatToFocus(
                        subStatsToFocus: [StatType.atk, StatType.critDmgPercentage, StatType.critRatePercentage],
                        color: color,
                        margin: EdgeInsets.zero,
                        fontSize: 13,
                      ),
                      // Wrap(
                      //   runSpacing: 2,
                      //   spacing: 10,
                      //   children: [
                      //     Text(
                      //       s.translateStatTypeWithoutValue(StatType.atk),
                      //       style: theme.textTheme.subtitle2!.copyWith(color: color),
                      //     ),
                      //     Text(
                      //       s.translateStatTypeWithoutValue(StatType.defPercentage),
                      //       style: theme.textTheme.subtitle2!.copyWith(color: color),
                      //     ),
                      //     Text(
                      //       s.translateStatTypeWithoutValue(StatType.hp),
                      //       style: theme.textTheme.subtitle2!.copyWith(color: color),
                      //     ),
                      //     Text(
                      //       s.translateStatTypeWithoutValue(StatType.geoDmgBonusPercentage),
                      //       style: theme.textTheme.subtitle2!.copyWith(color: color),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                splashRadius: Styles.smallButtonSplashRadius,
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
        // Wrap(
        //   alignment: WrapAlignment.center,
        //   crossAxisAlignment: WrapCrossAlignment.center,
        //   children: [
        //     ...artifacts
        //         .map(
        //           (e) => ArtifactCard.withoutDetails(
        //             keyName: e.key,
        //             name: s.translateStatTypeWithoutValue(e.statType),
        //             image: e.image,
        //             rarity: e.rarity,
        //           ),
        //         )
        //         .toList(),
        //     if (artifacts.length < ArtifactType.values.length)
        //       IconButton(
        //         color: theme.colorScheme.secondary,
        //         iconSize: 60,
        //         splashRadius: Styles.mediumBigButtonSplashRadius,
        //         icon: const Icon(Icons.add),
        //         onPressed: () => _addArtifact(context),
        //       ),
        //   ],
        // ),
        //TODO: IF HERE
        SubStatToFocus(
          subStatsToFocus: [StatType.atk, StatType.critDmgPercentage, StatType.critRatePercentage],
          color: color,
          fontSize: 14,
        ),
      ],
    );
  }

  Future<void> _addArtifact(BuildContext context) async {
    final bloc = context.read<CustomBuildBloc>();
    final selectedType = await showDialog<ArtifactType>(
      context: context,
      builder: (ctx) => SelectArtifactTypeDialog(
        selectedValues: artifacts.map((e) => e.type).toList(),
      ),
    );
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

    //TODO: REMOVE THE CROWNS AND MAYBE ONLY SHOW THE SPECIFIC TYPE
    final selectedKey = await ArtifactsPage.forSelection(context, type: selectedType);
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }
    bloc.add(CustomBuildEvent.addArtifact(key: selectedKey!, type: selectedType, statType: statType));
  }
}
