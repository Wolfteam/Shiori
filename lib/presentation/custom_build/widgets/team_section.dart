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
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class TeamSection extends StatelessWidget {
  final bool useBoxDecoration;

  const TeamSection({
    Key? key,
    required this.useBoxDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<CustomBuildBloc, CustomBuildState>(
      builder: (context, state) => state.maybeMap(
        loaded: (state) {
          final color = theme.brightness == Brightness.dark
              ? state.character.elementType.getElementColorFromContext(
                  context,
                )
              : theme.colorScheme.secondary;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: Styles.edgeInsetVertical10,
                decoration: BoxDecoration(
                  color: color,
                  border: useBoxDecoration ? const Border(top: BorderSide(color: Colors.white)) : null,
                ),
                child: Text(
                  state.readyForScreenshot
                      ? s.teamComposition
                      : '${s.teamComposition} (${state.teamCharacters.length} / ${CustomBuildBloc.maxNumberOfTeamCharacters})',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (!state.readyForScreenshot)
                ButtonBar(
                  buttonPadding: EdgeInsets.zero,
                  children: [
                    Tooltip(
                      message: s.add,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: Styles.smallButtonSplashRadius,
                        icon: const Icon(Icons.add),
                        onPressed: state.teamCharacters.length <= CustomBuildBloc.maxNumberOfTeamCharacters
                            ? () => _addTeamCharacter(context, state.teamCharacters.map((e) => e.key).toList(), state.character.key)
                            : null,
                      ),
                    ),
                    Tooltip(
                      message: s.sort,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: Styles.smallButtonSplashRadius,
                        icon: const Icon(Icons.sort),
                        onPressed: state.teamCharacters.length < 2
                            ? null
                            : () => showDialog(
                                  context: context,
                                  builder: (_) => SortItemsDialog(
                                    items: state.teamCharacters.map((e) => SortableItem(e.key, e.name)).toList(),
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
                        onPressed: state.teamCharacters.isEmpty
                            ? null
                            : () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.deleteTeamCharacters()),
                      ),
                    ),
                  ],
                ),
              if (state.teamCharacters.isEmpty)
                NothingFound(msg: s.startByAddingCharacters)
              else
                ...state.teamCharacters
                    .map(
                      (e) => TeamCharacterRow(
                        character: e,
                        teamCount: state.teamCharacters.length,
                        color: color,
                        readyToShare: state.readyForScreenshot,
                      ),
                    )
                    .toList(),
            ],
          );
        },
        orElse: () => const Loading(useScaffold: false),
      ),
    );
  }

  Future<void> _addTeamCharacter(BuildContext context, List<String> teamCharacterKeys, String characterKey) async {
    final bloc = context.read<CustomBuildBloc>();
    final exclude = [...teamCharacterKeys, characterKey];
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
