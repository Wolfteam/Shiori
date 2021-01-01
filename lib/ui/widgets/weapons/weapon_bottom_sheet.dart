import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/stat_type.dart';
import '../../../common/enums/weapon_filter_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/genshin_db_icons.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/bottom_sheet_title.dart';
import '../common/item_popupmenu_filter.dart';
import '../common/loading.dart';
import '../common/modal_sheet_separator.dart';
import '../common/rarity_rating.dart';
import '../common/sort_direction_popupmenu_filter.dart';
import '../common/weapons_button_bar.dart';

class WeaponBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final ignoredSubStats = [StatType.atk, StatType.critAtk, StatType.critRate, StatType.physDmgBonus];

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<WeaponsBloc, WeaponsState>(
          builder: (context, state) {
            return state.map(
              loading: (_) => const Loading(),
              loaded: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ModalSheetSeparator(),
                  BottomSheetTitle(icon: GenshinDb.filter, title: s.filters),
                  Text(s.type),
                  WeaponsButtonBar(
                    selectedValues: state.tempWeaponTypes,
                    onClick: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponTypeChanged(v)),
                  ),
                  Text(s.rarity),
                  RarityRating(
                    rarity: state.rarity,
                    onRated: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.rarityChanged(v)),
                  ),
                  Text(s.others),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ItemPopupMenuFilter<StatType>(
                        tooltipText: s.secondaryState,
                        onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponSubStatTypeChanged(v)),
                        selectedValue: state.tempWeaponSubStatType,
                        values: StatType.values.where((el) => !ignoredSubStats.contains(el)).toList(),
                        itemText: (val) => s.translateStatTypeWithoutValue(val),
                        icon: const Icon(GenshinDb.sliders_h, size: 18),
                      ),
                      ItemPopupMenuFilter<WeaponFilterType>(
                        tooltipText: s.sortBy,
                        onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponFilterTypeChanged(v)),
                        selectedValue: state.tempWeaponFilterType,
                        values: WeaponFilterType.values,
                        itemText: (val) => s.translateWeaponFilterType(val),
                      ),
                      SortDirectionPopupMenuFilter(
                        selectedSortDirection: state.tempSortDirectionType,
                        onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.sortDirectionTypeChanged(v)),
                      )
                    ],
                  ),
                  ButtonBar(
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                    children: <Widget>[
                      OutlineButton(
                        onPressed: () {
                          context.read<WeaponsBloc>().add(const WeaponsEvent.cancelChanges());
                          Navigator.pop(context);
                        },
                        child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                      ),
                      RaisedButton(
                        color: theme.primaryColor,
                        onPressed: () {
                          context.read<WeaponsBloc>().add(const WeaponsEvent.applyFilterChanges());
                          Navigator.pop(context);
                        },
                        child: Text(s.ok),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
