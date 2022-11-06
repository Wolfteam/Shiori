import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';
import 'package:shiori/presentation/shared/dialogs/select_character_skill_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/text_dialog.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class CharacterSection extends StatelessWidget {
  const CharacterSection({super.key});

  //TODO: FIGURE OUT A WAY TO SHOW THE IMAGE PROPERLY
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double imgHeight = height * 0.85;
    if (imgHeight > 1000) {
      imgHeight = 1000;
    }

    if (!isPortrait && imgHeight < 350) {
      imgHeight = 600;
    }
    final flexA = width < 400 ? 55 : 45;
    final flexB = width < 400 ? 45 : 55;

    final deviceType = getDeviceType(size);
    final useRowOnTalentsAndNotes = deviceType != DeviceScreenType.mobile && !isPortrait;

    return BlocBuilder<CustomBuildBloc, CustomBuildState>(
      builder: (context, state) => state.maybeMap(
        loaded: (state) => Container(
          color: theme.brightness == Brightness.dark
              ? state.character.elementType.getElementColorFromContext(
                  context,
                )
              : theme.colorScheme.secondary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: flexA,
                child: CharacterStackImage(
                  name: state.character.name,
                  image: state.character.image,
                  rarity: state.character.stars,
                  height: imgHeight,
                  onTap: () => _openCharacterPage(context, state.character.key),
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
                              state.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tooltip(
                            message: s.recommended,
                            child: IconButton(
                              splashRadius: Styles.smallButtonSplashRadius,
                              icon: Icon(state.isRecommended ? Icons.star : Icons.star_border_outlined),
                              onPressed: () => context.read<CustomBuildBloc>().add(
                                    CustomBuildEvent.isRecommendedChanged(newValue: !state.isRecommended),
                                  ),
                            ),
                          ),
                          if (!state.readyForScreenshot)
                            Tooltip(
                              message: s.edit,
                              child: IconButton(
                                splashRadius: Styles.smallButtonSplashRadius,
                                icon: const Icon(Icons.edit),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => TextDialog.update(
                                    hintText: s.title,
                                    value: state.title,
                                    maxLength: CustomBuildBloc.maxTitleLength,
                                    onSave: (newTitle) => context.read<CustomBuildBloc>().add(CustomBuildEvent.titleChanged(newValue: newTitle)),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                      if (!isPortrait)
                        Row(
                          children: [
                            Expanded(
                              flex: 48,
                              child: DropdownButtonWithTitle<CharacterRoleType>(
                                margin: EdgeInsets.zero,
                                title: s.role,
                                currentValue: state.type,
                                items: EnumUtils.getTranslatedAndSortedEnum<CharacterRoleType>(
                                  CharacterRoleType.values.where((el) => el != CharacterRoleType.na).toList(),
                                  (val, _) => s.translateCharacterRoleType(val),
                                ),
                                onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.roleChanged(newValue: v)),
                              ),
                            ),
                            const Spacer(flex: 4),
                            Expanded(
                              flex: 48,
                              child: DropdownButtonWithTitle<CharacterRoleSubType>(
                                margin: EdgeInsets.zero,
                                title: s.subType,
                                currentValue: state.subType,
                                items: EnumUtils.getTranslatedAndSortedEnum<CharacterRoleSubType>(
                                  CharacterRoleSubType.values,
                                  (val, _) => s.translateCharacterRoleSubType(val),
                                ),
                                onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.subRoleChanged(newValue: v)),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        DropdownButtonWithTitle<CharacterRoleType>(
                          margin: EdgeInsets.zero,
                          title: s.role,
                          currentValue: state.type,
                          items: EnumUtils.getTranslatedAndSortedEnum<CharacterRoleType>(
                            CharacterRoleType.values.where((el) => el != CharacterRoleType.na).toList(),
                            (val, _) => s.translateCharacterRoleType(val),
                          ),
                          onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.roleChanged(newValue: v)),
                        ),
                        DropdownButtonWithTitle<CharacterRoleSubType>(
                          margin: EdgeInsets.zero,
                          title: s.subType,
                          currentValue: state.subType,
                          items: EnumUtils.getTranslatedAndSortedEnum<CharacterRoleSubType>(
                            CharacterRoleSubType.values,
                            (val, _) => s.translateCharacterRoleSubType(val),
                          ),
                          onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.subRoleChanged(newValue: v)),
                        ),
                      ],
                      if (useRowOnTalentsAndNotes)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _TalentPriorityRow(skillPriorities: state.skillPriorities, readyToShare: state.readyForScreenshot),
                            ),
                            Expanded(
                              child: _NoteRow(notes: state.notes.map((e) => e.note).toList(), readyToShare: state.readyForScreenshot),
                            ),
                          ],
                        )
                      else ...[
                        _TalentPriorityRow(skillPriorities: state.skillPriorities, readyToShare: state.readyForScreenshot),
                        _NoteRow(notes: state.notes.map((e) => e.note).toList(), readyToShare: state.readyForScreenshot),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        orElse: () => const Loading(useScaffold: false),
      ),
    );
  }

  Future<void> _openCharacterPage(BuildContext context, String currentCharKey) async {
    final bloc = context.read<CustomBuildBloc>();
    final selectedKey = await CharactersPage.forSelection(context, excludeKeys: [currentCharKey]);
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }

    bloc.add(CustomBuildEvent.characterChanged(newKey: selectedKey!));
  }
}

class _TalentPriorityRow extends StatelessWidget {
  final List<CharacterSkillType> skillPriorities;
  final bool readyToShare;

  const _TalentPriorityRow({
    required this.skillPriorities,
    required this.readyToShare,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final canAddSkillPriorities = CustomBuildBloc.validSkillTypes.length == skillPriorities.length;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.talentPriority,
                style: theme.textTheme.subtitle1,
              ),
            ),
            if (!readyToShare)
              IconButton(
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.add),
                onPressed: canAddSkillPriorities
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (_) => SelectCharacterSkillTypeDialog(
                            excluded: CustomBuildBloc.excludedSkillTypes,
                            selectedValues: skillPriorities,
                            onSave: (type) {
                              if (type == null) {
                                return;
                              }

                              context.read<CustomBuildBloc>().add(CustomBuildEvent.addSkillPriority(type: type));
                            },
                          ),
                        ),
              ),
          ],
        ),
        if (skillPriorities.isNotEmpty)
          BulletList(
            iconSize: 14,
            items: skillPriorities.map((e) => s.translateCharacterSkillType(e)).toList(),
            iconResolver: (index) => Text('#${index + 1}', style: theme.textTheme.subtitle2!.copyWith(fontSize: 12)),
            fontSize: 10,
            addTooltip: false,
            padding: const EdgeInsets.only(right: 16, left: 5, bottom: 5, top: 5),
            onDelete: readyToShare ? null : (index) => context.read<CustomBuildBloc>().add(CustomBuildEvent.deleteSkillPriority(index: index)),
          )
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  final List<String> notes;
  final bool readyToShare;

  const _NoteRow({
    required this.notes,
    required this.readyToShare,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final canAddNotes = notes.map((e) => e.length).sum < (CustomBuildBloc.maxNumberOfNotes * CustomBuildBloc.maxNoteLength) &&
        notes.length < CustomBuildBloc.maxNumberOfNotes;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.notes,
                style: theme.textTheme.subtitle1,
              ),
            ),
            if (!readyToShare)
              IconButton(
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.add),
                onPressed: !canAddNotes
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (_) => TextDialog.create(
                            hintText: s.note,
                            onSave: (note) => context.read<CustomBuildBloc>().add(CustomBuildEvent.addNote(note: note)),
                            maxLength: CustomBuildBloc.maxNoteLength,
                          ),
                        ),
              ),
          ],
        ),
        if (notes.isNotEmpty)
          BulletList(
            iconSize: 14,
            items: notes,
            fontSize: 10,
            addTooltip: false,
            padding: const EdgeInsets.only(right: 16, left: 5, bottom: 5, top: 5),
            onDelete: readyToShare ? null : (index) => context.read<CustomBuildBloc>().add(CustomBuildEvent.deleteNote(index: index)),
          ),
      ],
    );
  }
}
