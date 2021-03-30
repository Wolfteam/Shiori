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
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';

class MonsterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return CommonBottomSheet(
      titleIcon: GenshinDb.filter,
      title: s.filters,
      onOk: () {
        context.read<MonstersBloc>().add(const MonstersEvent.applyFilterChanges());
        Navigator.pop(context);
      },
      onCancel: () {
        context.read<MonstersBloc>().add(const MonstersEvent.cancelChanges());
        Navigator.pop(context);
      },
      child: BlocBuilder<MonstersBloc, MonstersState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(s.others),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ItemPopupMenuFilter<MonsterType>(
                    tooltipText: s.type,
                    onSelected: (v) => context.read<MonstersBloc>().add(MonstersEvent.typeChanged(v)),
                    selectedValue: state.tempType,
                    values: MonsterType.values,
                    itemText: (val) => s.translateMonsterType(val),
                  ),
                  ItemPopupMenuFilter<MonsterFilterType>(
                    tooltipText: s.sortBy,
                    onSelected: (v) => context.read<MonstersBloc>().add(MonstersEvent.filterTypeChanged(v)),
                    selectedValue: state.tempFilterType,
                    values: MonsterFilterType.values,
                    itemText: (val) => s.translateMonsterFilterType(val),
                  ),
                  SortDirectionPopupMenuFilter(
                    selectedSortDirection: state.tempSortDirectionType,
                    onSelected: (v) => context.read<MonstersBloc>().add(MonstersEvent.sortDirectionTypeChanged(v)),
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
