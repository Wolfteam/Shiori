import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/elements_button_bar.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/rarity_rating.dart';
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/weapons_button_bar.dart';

class CharacterBottomSheet extends StatelessWidget {
  const CharacterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonBottomSheet(
      titleIcon: GenshinDb.filter,
      title: s.filters,
      onOk: () {
        context.read<CharactersBloc>().add(const CharactersEvent.applyFilterChanges());
        Navigator.pop(context);
      },
      onCancel: () {
        context.read<CharactersBloc>().add(const CharactersEvent.cancelChanges());
        Navigator.pop(context);
      },
      child: BlocBuilder<CharactersBloc, CharactersState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(s.elements),
              ElementsButtonBar(
                selectedValues: state.tempElementTypes,
                onClick: (v) => context.read<CharactersBloc>().add(CharactersEvent.elementTypeChanged(v)),
              ),
              Text(s.weapons),
              WeaponsButtonBar(
                selectedValues: state.tempWeaponTypes,
                onClick: (v) => context.read<CharactersBloc>().add(CharactersEvent.weaponTypeChanged(v)),
              ),
              Text(s.rarity),
              RarityRating(
                rarity: state.rarity,
                onRated: (v) => context.read<CharactersBloc>().add(CharactersEvent.rarityChanged(v)),
              ),
              Text(s.others),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ItemPopupMenuFilter<CharacterRoleType>(
                    tooltipText: s.role,
                    values: CharacterRoleType.values.where((el) => el != CharacterRoleType.na).toList(),
                    selectedValue: state.tempRoleType,
                    onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.roleTypeChanged(v)),
                    itemText: (val) => s.translateCharacterType(val),
                    icon: const Icon(GenshinDb.trefoil_lily, size: 18),
                  ),
                  ItemPopupMenuFilter<ItemStatusType>(
                    tooltipText: '${s.released} / ${s.brandNew} / ${s.comingSoon}',
                    values: ItemStatusType.values,
                    selectedValue: state.tempStatusType,
                    onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.itemStatusChanged(v)),
                    icon: const Icon(GenshinDb.sliders_h, size: 18),
                    itemText: (val) => s.translateReleasedUnreleasedType(val),
                  ),
                  ItemPopupMenuFilter<CharacterFilterType>(
                    tooltipText: s.sortBy,
                    values: CharacterFilterType.values,
                    selectedValue: state.tempCharacterFilterType,
                    onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.characterFilterTypeChanged(v)),
                    itemText: (val) => s.translateCharacterFilterType(val),
                  ),
                  SortDirectionPopupMenuFilter(
                    selectedSortDirection: state.tempSortDirectionType,
                    onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.sortDirectionTypeChanged(v)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
