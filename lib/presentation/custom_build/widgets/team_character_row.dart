import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/custom_builds/custom_build_team_character_model.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/select_character_role_sub_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/select_character_role_type_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';

enum _Options {
  delete,
  update,
}

class TeamCharacterRow extends StatelessWidget {
  final CustomBuildTeamCharacterModel character;
  final Color color;
  final bool readyToShare;

  const TeamCharacterRow({
    super.key,
    required this.character,
    required this.color,
    required this.readyToShare,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleCharacter(
          itemKey: character.key,
          image: character.iconImage,
          radius: 55,
        ),
        Expanded(
          child: Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  character.name,
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${s.role}: ${s.translateCharacterRoleType(character.roleType)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(color: color),
                ),
                if (character.subType != CharacterRoleSubType.none)
                  Text(
                    '${s.subType}: ${s.translateCharacterRoleSubType(character.subType)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium!.copyWith(color: color),
                  ),
              ],
            ),
          ),
        ),
        if (!readyToShare)
          ItemPopupMenuFilter<_Options>.withoutSelectedValue(
            values: _Options.values,
            tooltipText: s.options,
            icon: const Icon(Icons.more_vert),
            onSelected: (type) => _handleOptionSelected(context, type),
            childBuilder: (e) {
              Widget icon;
              switch (e.enumValue) {
                case _Options.delete:
                  icon = const Icon(Icons.delete);
                case _Options.update:
                  icon = const Icon(Icons.edit);
                default:
                  throw Exception('The provided team character option type = ${e.enumValue} is not valid');
              }

              return Row(
                children: [
                  icon,
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(e.translation, overflow: TextOverflow.ellipsis),
                  ),
                ],
              );
            },
            itemText: (type, _) {
              switch (type) {
                case _Options.delete:
                  return s.delete;
                case _Options.update:
                  return s.update;
                default:
                  throw Exception('The provided team character option type = $type is not valid');
              }
            },
          ),
      ],
    );
  }

  Future<void> _handleOptionSelected(BuildContext context, _Options option) async {
    final bloc = context.read<CustomBuildBloc>();
    switch (option) {
      case _Options.delete:
        bloc.add(CustomBuildEvent.deleteTeamCharacter(key: character.key));
      case _Options.update:
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

        bloc.add(CustomBuildEvent.addTeamCharacter(key: character.key, roleType: roleType, subType: subType));
      default:
        throw Exception('The team character option is not valid');
    }
  }
}
