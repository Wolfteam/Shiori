import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/custom_build/widgets/team_character_row.dart';
import 'package:shiori/presentation/shared/dialogs/select_character_role_sub_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/select_character_role_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/sort_items_dialog.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class TeamSection extends StatelessWidget {
  final String mainCharKey;
  final List<CustomBuildTeamCharacterModel> teamCharacters;
  final Color color;

  const TeamSection({
    Key? key,
    required this.mainCharKey,
    required this.color,
    required this.teamCharacters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: Styles.edgeInsetVertical10,
          // margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: color,
            border: isPortrait ? const Border(top: BorderSide(color: Colors.white)) : null,
          ),
          child: Text(
            '${s.teamComposition} (${teamCharacters.length} / ${CustomBuildBloc.maxNumberOfTeamCharacters})',
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ButtonBar(
          buttonPadding: EdgeInsets.zero,
          children: [
            Tooltip(
              message: s.add,
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.add),
                onPressed: teamCharacters.length <= CustomBuildBloc.maxNumberOfTeamCharacters ? () => _addTeamCharacter(context) : null,
              ),
            ),
            Tooltip(
              message: s.sort,
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.sort),
                onPressed: teamCharacters.length < 2
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (_) => SortItemsDialog(
                            items: teamCharacters.map((e) => SortableItem(e.key, e.name)).toList(),
                            onSave: (result) {
                              if (!result.somethingChanged) {
                                return;
                              }

                              context.read<CustomBuildBloc>().add(CustomBuildEvent.teamCharactersOrderChanged(characters: result.items));
                            },
                          ),
                        ),
              ),
            ),
            Tooltip(
              message: s.clearAll,
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.clear_all),
                onPressed: teamCharacters.isEmpty ? null : () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.deleteTeamCharacters()),
              ),
            ),
          ],
        ),
        if (teamCharacters.isEmpty)
          NothingFound(msg: s.startByAddingCharacters)
        else
          ...teamCharacters.map((e) => TeamCharacterRow(character: e, teamCount: teamCharacters.length, color: color)).toList(),
      ],
    );
  }

  Future<void> _addTeamCharacter(BuildContext context) async {
    final bloc = context.read<CustomBuildBloc>();
    final exclude = [...teamCharacters.map((e) => e.key), mainCharKey];
    final key = await CharactersPage.forSelection(context, excludeKeys: exclude);
    if (key.isNullEmptyOrWhitespace) {
      return;
    }

    final roleType = await showDialog<CharacterRoleType>(
      context: context,
      builder: (_) => const SelectCharacterRoleTypeDialog(
        excluded: [CharacterRoleType.na],
      ),
    );
    if (roleType == null) {
      return;
    }

    final subType = await showDialog<CharacterRoleSubType>(context: context, builder: (_) => const SelectCharacterRoleSubTypeDialog());
    if (subType == null) {
      return;
    }

    bloc.add(CustomBuildEvent.addTeamCharacter(key: key!, roleType: roleType, subType: subType));
  }
}
