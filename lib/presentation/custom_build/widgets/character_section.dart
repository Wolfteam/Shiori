import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';
import 'package:shiori/presentation/shared/dialogs/select_character_skill_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/text_dialog.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class CharacterSection extends StatelessWidget {
  final String title;
  final CharacterRoleType type;
  final CharacterRoleSubType subType;
  final bool showOnCharacterDetail;
  final bool isRecommended;
  final CharacterCardModel character;
  final List<CustomBuildNoteModel> notes;
  final List<CharacterSkillType> skillPriorities;

  const CharacterSection({
    Key? key,
    required this.title,
    required this.type,
    required this.subType,
    required this.showOnCharacterDetail,
    required this.isRecommended,
    required this.character,
    required this.notes,
    required this.skillPriorities,
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
    final canAddNotes = notes.map((e) => e.note.length).sum < 300 && notes.length < CustomBuildBloc.maxNumberOfNotes;
    final canAddSkillPriorities = CustomBuildBloc.validSkillTypes.length == skillPriorities.length;
    return Container(
      color: character.elementType.getElementColorFromContext(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tooltip(
                        message: s.recommended,
                        child: IconButton(
                          splashRadius: Styles.smallButtonSplashRadius,
                          icon: Icon(isRecommended ? Icons.star : Icons.star_border_outlined),
                          onPressed: () => context.read<CustomBuildBloc>().add(CustomBuildEvent.isRecommendedChanged(newValue: !isRecommended)),
                        ),
                      ),
                      Tooltip(
                        message: s.edit,
                        child: IconButton(
                          splashRadius: Styles.smallButtonSplashRadius,
                          icon: const Icon(Icons.edit),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => TextDialog.update(
                              title: s.title,
                              value: title,
                              maxLength: CustomBuildBloc.maxTitleLength,
                              onSave: (newTitle) => context.read<CustomBuildBloc>().add(CustomBuildEvent.titleChanged(newValue: newTitle)),
                            ),
                          ),
                        ),
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
                    title: s.subType,
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
                    title: Text(s.showOnCharacterDetail),
                    value: showOnCharacterDetail,
                    onChanged: (v) => context.read<CustomBuildBloc>().add(CustomBuildEvent.showOnCharacterDetailChanged(newValue: v)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.talentPriority,
                          style: theme.textTheme.subtitle1,
                        ),
                      ),
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
                  BulletList(
                    iconSize: 12,
                    items: skillPriorities.map((e) => s.translateCharacterSkillType(e)).toList(),
                    iconResolver: (index) => Text('#${index + 1}'),
                    onDelete: (index) => context.read<CustomBuildBloc>().add(CustomBuildEvent.deleteSkillPriority(index: index)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.notes,
                          style: theme.textTheme.subtitle1,
                        ),
                      ),
                      IconButton(
                        splashRadius: Styles.smallButtonSplashRadius,
                        icon: const Icon(Icons.add),
                        onPressed: !canAddNotes
                            ? null
                            : () => showDialog(
                                  context: context,
                                  builder: (_) => TextDialog.create(
                                    title: s.note,
                                    onSave: (note) => context.read<CustomBuildBloc>().add(CustomBuildEvent.addNote(note: note)),
                                    maxLength: CustomBuildBloc.maxNoteLength,
                                  ),
                                ),
                      ),
                    ],
                  ),
                  BulletList(
                    iconSize: 12,
                    items: notes.map((e) => e.note).toList(),
                    onDelete: (index) => context.read<CustomBuildBloc>().add(CustomBuildEvent.deleteNote(index: index)),
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
