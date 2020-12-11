import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/artifact_filter_type.dart';
import '../../../common/enums/sort_direction_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/bottom_sheet_title.dart';
import '../common/item_popupmenu_filter.dart';
import '../common/loading.dart';
import '../common/modal_sheet_separator.dart';
import '../common/sort_direction_popupmenu_filter.dart';

class ArtifactBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<ArtifactsBloc, ArtifactsState>(
          builder: (context, state) {
            return state.map(
              loading: (_) => const Loading(),
              loaded: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ModalSheetSeparator(),
                  BottomSheetTitle(icon: Icons.playlist_play, title: s.filters),
                  Text(s.rarity),
                  Center(
                    child: SmoothStarRating(
                      rating: state.rarity.toDouble(),
                      allowHalfRating: false,
                      onRated: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.rarityChanged(v.toInt())),
                      size: 35.0,
                      color: Colors.yellow,
                      borderColor: Colors.yellow,
                    ),
                  ),
                  Text(s.others),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ItemPopupMenuFilter<ArtifactFilterType>(
                        tooltipText: s.sortBy,
                        onSelected: (v) =>
                            context.read<ArtifactsBloc>().add(ArtifactsEvent.artifactFilterTypeChanged(v)),
                        selectedValue: state.tempArtifactFilterType,
                        values: ArtifactFilterType.values,
                        itemText: (val) => s.translateArtifactFilterType(val),
                      ),
                      SortDirectionPopupMenuFilter(
                        selectedSortDirection: state.tempSortDirectionType,
                        onSelected: (v) =>
                            context.read<ArtifactsBloc>().add(ArtifactsEvent.sortDirectionTypeChanged(v)),
                      )
                    ],
                  ),
                  ButtonBar(
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                    children: <Widget>[
                      OutlineButton(
                        onPressed: () {
                          context.read<ArtifactsBloc>().add(const ArtifactsEvent.cancelChanges());
                          Navigator.pop(context);
                        },
                        child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                      ),
                      RaisedButton(
                        color: theme.primaryColor,
                        onPressed: () {
                          context.read<ArtifactsBloc>().add(const ArtifactsEvent.applyFilterChanges());
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
