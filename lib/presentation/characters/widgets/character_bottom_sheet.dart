import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/right_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/elements_button_bar.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/rarity_rating.dart';
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/weapons_button_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CharacterBottomSheet extends StatelessWidget {
  const CharacterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;
    if (!forEndDrawer) {
      return CommonBottomSheet(
        titleIcon: GenshinDb.filter,
        title: s.filters,
        showCancelButton: false,
        showOkButton: false,
        child: BlocBuilder<CharactersBloc, CharactersState>(
          builder: (context, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
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
                _OtherFilters(
                  tempCharacterFilterType: state.tempCharacterFilterType,
                  tempRoleType: state.tempRoleType,
                  tempSortDirectionType: state.tempSortDirectionType,
                  tempStatusType: state.tempStatusType,
                  tempRegionType: state.tempRegionType,
                ),
                const _ButtonBar(),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => RightBottomSheet(
          bottom: const _ButtonBar(),
          children: [
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.elements)),
            ElementsButtonBar(
              selectedValues: state.tempElementTypes,
              iconSize: Styles.endDrawerIconSize,
              onClick: (v) => context.read<CharactersBloc>().add(CharactersEvent.elementTypeChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.weapons)),
            WeaponsButtonBar(
              selectedValues: state.tempWeaponTypes,
              iconSize: Styles.endDrawerIconSize,
              onClick: (v) => context.read<CharactersBloc>().add(CharactersEvent.weaponTypeChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.rarity)),
            RarityRating(
              rarity: state.rarity,
              size: Styles.endDrawerIconSize,
              onRated: (v) => context.read<CharactersBloc>().add(CharactersEvent.rarityChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.others)),
            _OtherFilters(
              tempCharacterFilterType: state.tempCharacterFilterType,
              tempRoleType: state.tempRoleType,
              tempSortDirectionType: state.tempSortDirectionType,
              tempStatusType: state.tempStatusType,
              tempRegionType: state.tempRegionType,
              forEndDrawer: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherFilters extends StatelessWidget {
  final ItemStatusType tempStatusType;
  final CharacterRoleType tempRoleType;
  final RegionType? tempRegionType;
  final CharacterFilterType tempCharacterFilterType;
  final SortDirectionType tempSortDirectionType;
  final bool forEndDrawer;

  const _OtherFilters({
    Key? key,
    required this.tempStatusType,
    required this.tempRoleType,
    this.tempRegionType,
    required this.tempCharacterFilterType,
    required this.tempSortDirectionType,
    this.forEndDrawer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      spacing: 5,
      alignment: WrapAlignment.spaceBetween,
      children: [
        ItemPopupMenuFilter<ItemStatusType>(
          tooltipText: '${s.released} / ${s.brandNew} / ${s.comingSoon}',
          values: ItemStatusType.values,
          selectedValue: tempStatusType,
          onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.itemStatusChanged(v)),
          icon: Icon(GenshinDb.sliders_h, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
          itemText: (val) => s.translateReleasedUnreleasedType(val),
        ),
        ItemPopupMenuFilter<CharacterRoleType>(
          tooltipText: s.role,
          values: CharacterRoleType.values.where((el) => el != CharacterRoleType.na).toList(),
          selectedValue: tempRoleType,
          onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.roleTypeChanged(v)),
          itemText: (val) => s.translateCharacterType(val),
          icon: Icon(GenshinDb.trefoil_lily, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilterWithAllValue(
          tooltipText: s.region,
          values: RegionType.values.map((e) => e.index).toList(),
          selectedValue: tempRegionType?.index,
          onAllOrValueSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.regionTypeChanged(v == null ? null : RegionType.values[v])),
          itemText: (val) => s.translateRegionType(RegionType.values[val]),
          icon: Icon(GenshinDb.reactor, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilter<CharacterFilterType>(
          tooltipText: s.sortBy,
          values: CharacterFilterType.values,
          selectedValue: tempCharacterFilterType,
          onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.characterFilterTypeChanged(v)),
          itemText: (val) => s.translateCharacterFilterType(val),
          icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: tempSortDirectionType,
          onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.sortDirectionTypeChanged(v)),
          icon: Icon(Icons.sort, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        )
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  const _ButtonBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CommonButtonBar(
      children: <Widget>[
        OutlinedButton(
          onPressed: () {
            context.read<CharactersBloc>().add(const CharactersEvent.cancelChanges());
            Navigator.pop(context);
          },
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        OutlinedButton(
          onPressed: () {
            context.read<CharactersBloc>().add(const CharactersEvent.resetFilters());
            Navigator.pop(context);
          },
          child: Text(s.reset, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CharactersBloc>().add(const CharactersEvent.applyFilterChanges());
            Navigator.pop(context);
          },
          child: Text(s.ok),
        )
      ],
    );
  }
}
