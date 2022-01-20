import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_section.dart';
import 'package:shiori/presentation/custom_build/widgets/character_section.dart';
import 'package:shiori/presentation/custom_build/widgets/team_section.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_section.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

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
    final s = S.of(context);
    //https://genshin-impact-card-generator.herokuapp.com/
    return BlocProvider(
      create: (ctx) => Injection.getCustomBuildBloc(context.read<CustomBuildsBloc>())..add(CustomBuildEvent.load(key: itemKey, initialTitle: s.dps)),
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
    return BlocBuilder<CustomBuildBloc, CustomBuildState>(
      builder: (ctx, state) => state.maybeMap(
        loaded: (state) => Scaffold(
          appBar: _AppBar(
            newBuild: widget.newBuild,
            canSave: state.artifacts.length == ArtifactType.values.length && state.weapons.isNotEmpty,
            screenshotController: _screenshotController,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 10),
            child: Screenshot(
              controller: _screenshotController,
              child: OrientationLayoutBuilder(
                portrait: (context) => _PortraitLayout(
                  title: state.title,
                  roleType: state.type,
                  roleSubType: state.subType,
                  showOnCharacterDetail: state.showOnCharacterDetail,
                  isRecommended: state.isRecommended,
                  character: state.character,
                  weapons: state.weapons,
                  artifacts: state.artifacts,
                  teamCharacters: state.teamCharacters,
                  notes: state.notes,
                  skillPriorities: state.skillPriorities,
                  subStatsSummary: state.subStatsSummary,
                ),
                landscape: (context) => width > 1280
                    ? _LandscapeLayout(
                        title: state.title,
                        roleType: state.type,
                        roleSubType: state.subType,
                        showOnCharacterDetail: state.showOnCharacterDetail,
                        isRecommended: state.isRecommended,
                        character: state.character,
                        weapons: state.weapons,
                        artifacts: state.artifacts,
                        teamCharacters: state.teamCharacters,
                        notes: state.notes,
                        skillPriorities: state.skillPriorities,
                        subStatsSummary: state.subStatsSummary,
                      )
                    : _PortraitLayout(
                        title: state.title.isNullEmptyOrWhitespace ? s.dps : state.title,
                        roleType: state.type,
                        roleSubType: state.subType,
                        showOnCharacterDetail: state.showOnCharacterDetail,
                        isRecommended: state.isRecommended,
                        character: state.character,
                        weapons: state.weapons,
                        artifacts: state.artifacts,
                        teamCharacters: state.teamCharacters,
                        notes: state.notes,
                        skillPriorities: state.skillPriorities,
                        subStatsSummary: state.subStatsSummary,
                      ),
              ),
            ),
          ),
        ),
        orElse: () => const Loading(),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool newBuild;
  final bool canSave;
  final ScreenshotController screenshotController;

  const _AppBar({
    Key? key,
    required this.newBuild,
    required this.canSave,
    required this.screenshotController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AppBar(
      title: Text(newBuild ? s.add : s.edit),
      actions: [
        IconButton(
          splashRadius: Styles.mediumButtonSplashRadius,
          icon: const Icon(Icons.save),
          onPressed: !canSave ? null : () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.saveChanges()),
        ),
        IconButton(
          splashRadius: Styles.mediumButtonSplashRadius,
          icon: const Icon(Icons.share),
          onPressed: () => _takeScreenshot(context),
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
  final bool isRecommended;
  final CharacterCardModel character;
  final List<CustomBuildWeaponModel> weapons;
  final List<CustomBuildArtifactModel> artifacts;
  final List<CustomBuildTeamCharacterModel> teamCharacters;
  final List<CustomBuildNoteModel> notes;
  final List<CharacterSkillType> skillPriorities;
  final List<StatType> subStatsSummary;

  const _PortraitLayout({
    Key? key,
    required this.title,
    required this.roleType,
    required this.roleSubType,
    required this.showOnCharacterDetail,
    required this.isRecommended,
    required this.character,
    required this.weapons,
    required this.artifacts,
    required this.teamCharacters,
    required this.notes,
    required this.skillPriorities,
    required this.subStatsSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CharacterSection(
          title: title,
          type: roleType,
          subType: roleSubType,
          showOnCharacterDetail: showOnCharacterDetail,
          isRecommended: isRecommended,
          character: character,
          notes: notes,
          skillPriorities: skillPriorities,
        ),
        ScreenTypeLayout.builder(
          desktop: (context) => _WeaponsAndArtifacts(
            mainCharKey: character.key,
            weaponType: character.weaponType,
            color: character.elementType.getElementColorFromContext(context),
            weapons: weapons,
            artifacts: artifacts,
            teamCharacters: teamCharacters,
            subStatsSummary: subStatsSummary,
          ),
          tablet: (context) => _WeaponsAndArtifacts(
            mainCharKey: character.key,
            weaponType: character.weaponType,
            color: character.elementType.getElementColorFromContext(context),
            weapons: weapons,
            artifacts: artifacts,
            teamCharacters: teamCharacters,
            subStatsSummary: subStatsSummary,
          ),
          mobile: (context) => _WeaponsAndArtifacts(
            useColumn: isPortrait,
            mainCharKey: character.key,
            weaponType: character.weaponType,
            color: character.elementType.getElementColorFromContext(context),
            weapons: weapons,
            artifacts: artifacts,
            teamCharacters: teamCharacters,
            subStatsSummary: subStatsSummary,
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
  final bool isRecommended;
  final CharacterCardModel character;
  final List<CustomBuildWeaponModel> weapons;
  final List<CustomBuildArtifactModel> artifacts;
  final List<CustomBuildTeamCharacterModel> teamCharacters;
  final List<CustomBuildNoteModel> notes;
  final List<CharacterSkillType> skillPriorities;
  final List<StatType> subStatsSummary;

  const _LandscapeLayout({
    Key? key,
    required this.title,
    required this.roleType,
    required this.roleSubType,
    required this.showOnCharacterDetail,
    required this.isRecommended,
    required this.character,
    required this.weapons,
    required this.artifacts,
    required this.teamCharacters,
    required this.notes,
    required this.skillPriorities,
    required this.subStatsSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 40,
          child: CharacterSection(
            title: title,
            type: roleType,
            subType: roleSubType,
            showOnCharacterDetail: showOnCharacterDetail,
            isRecommended: isRecommended,
            character: character,
            notes: notes,
            skillPriorities: skillPriorities,
          ),
        ),
        Expanded(
          flex: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WeaponSection(
                  weapons: weapons,
                  weaponType: character.weaponType,
                  color: character.elementType.getElementColorFromContext(context),
                  maxItemImageWidth: _maxItemImageWidth,
                ),
              ),
              Expanded(
                child: ArtifactSection(
                  artifacts: artifacts,
                  color: character.elementType.getElementColorFromContext(context),
                  maxItemImageWidth: _maxItemImageWidth,
                  subStatsSummary: subStatsSummary,
                ),
              ),
              Expanded(
                child: TeamSection(
                  mainCharKey: character.key,
                  teamCharacters: teamCharacters,
                  color: character.elementType.getElementColorFromContext(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeaponsAndArtifacts extends StatelessWidget {
  final String mainCharKey;
  final WeaponType weaponType;
  final List<CustomBuildWeaponModel> weapons;
  final List<CustomBuildArtifactModel> artifacts;
  final List<CustomBuildTeamCharacterModel> teamCharacters;
  final bool useColumn;
  final List<StatType> subStatsSummary;
  final Color color;

  const _WeaponsAndArtifacts({
    Key? key,
    required this.mainCharKey,
    required this.weaponType,
    required this.weapons,
    required this.artifacts,
    required this.teamCharacters,
    this.useColumn = false,
    required this.subStatsSummary,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useColumn) {
      return Column(
        children: [
          WeaponSection(
            weapons: weapons,
            weaponType: weaponType,
            color: color,
            maxItemImageWidth: _maxItemImageWidth,
          ),
          ArtifactSection(
            artifacts: artifacts,
            color: color,
            maxItemImageWidth: _maxItemImageWidth,
            subStatsSummary: subStatsSummary,
          ),
          TeamSection(
            mainCharKey: mainCharKey,
            teamCharacters: teamCharacters,
            color: color,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WeaponSection(
                weapons: weapons,
                weaponType: weaponType,
                color: color,
                maxItemImageWidth: _maxItemImageWidth,
              ),
            ),
            Expanded(
              child: ArtifactSection(
                artifacts: artifacts,
                color: color,
                maxItemImageWidth: _maxItemImageWidth,
                subStatsSummary: subStatsSummary,
              ),
            ),
          ],
        ),
        TeamSection(
          mainCharKey: mainCharKey,
          teamCharacters: teamCharacters,
          color: color,
        ),
      ],
    );
  }
}
