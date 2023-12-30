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
import 'package:shiori/presentation/shared/rarity_rating.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ArtifactBottomSheet extends StatelessWidget {
  const ArtifactBottomSheet({
    super.key,
  });

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
        child: BlocBuilder<ArtifactsBloc, ArtifactsState>(
          builder: (context, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
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
                _OtherFilters(
                  tempSortDirectionType: state.tempSortDirectionType,
                  tempArtifactFilterType: state.tempArtifactFilterType,
                ),
                const _ButtonBar(),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<ArtifactsBloc, ArtifactsState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => RightBottomSheet(
          bottom: const _ButtonBar(),
          children: [
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.rarity)),
            RarityRating(
              rarity: state.rarity,
              onRated: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.rarityChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.others)),
            _OtherFilters(
              tempSortDirectionType: state.tempSortDirectionType,
              tempArtifactFilterType: state.tempArtifactFilterType,
              forEndDrawer: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherFilters extends StatelessWidget {
  final ArtifactFilterType tempArtifactFilterType;
  final SortDirectionType tempSortDirectionType;
  final bool forEndDrawer;

  const _OtherFilters({
    required this.tempArtifactFilterType,
    required this.tempSortDirectionType,
    this.forEndDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        ItemPopupMenuFilter<ArtifactFilterType>(
          tooltipText: s.sortBy,
          onSelected: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.artifactFilterTypeChanged(v)),
          selectedValue: tempArtifactFilterType,
          values: ArtifactFilterType.values,
          itemText: (val, _) => s.translateArtifactFilterType(val),
          icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: tempSortDirectionType,
          onSelected: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.sortDirectionTypeChanged(v)),
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
            context.read<ArtifactsBloc>().add(const ArtifactsEvent.cancelChanges());
            Navigator.pop(context);
          },
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        TextButton(
          onPressed: () {
            context.read<ArtifactsBloc>().add(const ArtifactsEvent.resetFilters());
            Navigator.pop(context);
          },
          child: Text(s.reset, style: TextStyle(color: theme.primaryColor)),
        ),
        FilledButton(
          onPressed: () {
            context.read<ArtifactsBloc>().add(const ArtifactsEvent.applyFilterChanges());
            Navigator.pop(context);
          },
          child: Text(s.ok),
        ),
      ],
    );
  }
}
