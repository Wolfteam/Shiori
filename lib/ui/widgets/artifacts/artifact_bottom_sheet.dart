import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/artifact_filter_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/genshin_db_icons.dart';
import '../../../generated/l10n.dart';
import '../common/common_bottom_sheet.dart';
import '../common/item_popupmenu_filter.dart';
import '../common/loading.dart';
import '../common/rarity_rating.dart';
import '../common/sort_direction_popupmenu_filter.dart';

class ArtifactBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonBottomSheet(
      titleIcon: GenshinDb.filter,
      title: s.filters,
      onOk: () {
        context.read<ArtifactsBloc>().add(const ArtifactsEvent.applyFilterChanges());
        Navigator.pop(context);
      },
      onCancel: () {
        context.read<ArtifactsBloc>().add(const ArtifactsEvent.cancelChanges());
        Navigator.pop(context);
      },
      child: BlocBuilder<ArtifactsBloc, ArtifactsState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(s.rarity),
              RarityRating(
                rarity: state.rarity,
                onRated: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.rarityChanged(v)),
              ),
              Text(s.others),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ItemPopupMenuFilter<ArtifactFilterType>(
                    tooltipText: s.sortBy,
                    onSelected: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.artifactFilterTypeChanged(v)),
                    selectedValue: state.tempArtifactFilterType,
                    values: ArtifactFilterType.values,
                    itemText: (val) => s.translateArtifactFilterType(val),
                  ),
                  SortDirectionPopupMenuFilter(
                    selectedSortDirection: state.tempSortDirectionType,
                    onSelected: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.sortDirectionTypeChanged(v)),
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
