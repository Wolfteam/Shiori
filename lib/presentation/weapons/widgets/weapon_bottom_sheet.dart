import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/rarity_rating.dart';
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/weapons_button_bar.dart';

class WeaponBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final ignoredSubStats = [StatType.atk, StatType.critAtk, StatType.critRate, StatType.physDmgBonus];

    return CommonBottomSheet(
      titleIcon: GenshinDb.filter,
      title: s.filters,
      onOk: () {
        context.read<WeaponsBloc>().add(const WeaponsEvent.applyFilterChanges());
        Navigator.pop(context);
      },
      onCancel: () {
        context.read<WeaponsBloc>().add(const WeaponsEvent.cancelChanges());
        Navigator.pop(context);
      },
      child: BlocBuilder<WeaponsBloc, WeaponsState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
