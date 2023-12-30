import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:shiori/presentation/shared/bottom_sheets/right_bottom_sheet.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';

class MonsterBottomSheet extends StatelessWidget {
  const MonsterBottomSheet({super.key});

  static Widget route(BuildContext context) {
    return BlocProvider.value(
      value: context.read<MonstersBloc>(),
      child: const MonsterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;

    if (!forEndDrawer) {
      return CommonBottomSheet(
        titleIcon: Shiori.filter,
        title: s.filters,
        showCancelButton: false,
        showOkButton: false,
        child: BlocBuilder<MonstersBloc, MonstersState>(
          builder: (context, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(s.others),
                _OtherFilters(
                  tempType: state.tempType,
                  tempSortDirectionType: state.tempSortDirectionType,
                  tempFilterType: state.tempFilterType,
                  forEndDrawer: forEndDrawer,
                ),
                const _ButtonBar(),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<MonstersBloc, MonstersState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => RightBottomSheet(
          bottom: const _ButtonBar(),
          children: [
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.others)),
            _OtherFilters(
              tempFilterType: state.tempFilterType,
              tempSortDirectionType: state.tempSortDirectionType,
              tempType: state.tempType,
              forEndDrawer: forEndDrawer,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherFilters extends StatelessWidget {
  final MonsterType? tempType;
  final MonsterFilterType tempFilterType;
  final SortDirectionType tempSortDirectionType;
  final bool forEndDrawer;

  const _OtherFilters({
    required this.tempType,
    required this.tempFilterType,
    required this.tempSortDirectionType,
    required this.forEndDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        ItemPopupMenuFilterWithAllValue(
          tooltipText: s.type,
          onAllOrValueSelected: (v) => context.read<MonstersBloc>().add(MonstersEvent.typeChanged(v != null ? MonsterType.values[v] : null)),
          selectedValue: tempType?.index,
          values: MonsterType.values.map((e) => e.index).toList(),
          itemText: (val, _) => s.translateMonsterType(MonsterType.values[val]),
          icon: Icon(Icons.filter_list_alt, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        ItemPopupMenuFilter<MonsterFilterType>(
          tooltipText: s.sortBy,
          onSelected: (v) => context.read<MonstersBloc>().add(MonstersEvent.filterTypeChanged(v)),
          selectedValue: tempFilterType,
          values: MonsterFilterType.values,
          itemText: (val, _) => s.translateMonsterFilterType(val),
          icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: tempSortDirectionType,
          onSelected: (v) => context.read<MonstersBloc>().add(MonstersEvent.sortDirectionTypeChanged(v)),
          icon: Icon(Icons.sort, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  const _ButtonBar();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CommonButtonBar(
      children: <Widget>[
        TextButton(
          onPressed: () {
            context.read<MonstersBloc>().add(const MonstersEvent.cancelChanges());
            Navigator.pop(context);
          },
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        TextButton(
          onPressed: () {
            context.read<MonstersBloc>().add(const MonstersEvent.resetFilters());
            Navigator.pop(context);
          },
          child: Text(s.reset, style: TextStyle(color: theme.primaryColor)),
        ),
        FilledButton(
          onPressed: () {
            context.read<MonstersBloc>().add(const MonstersEvent.applyFilterChanges());
            Navigator.pop(context);
          },
          child: Text(s.ok),
        ),
      ],
    );
  }
}
