import 'package:flutter/material.dart';
import 'package:genshindb/common/enums/artifact_filter_type.dart';
import 'package:genshindb/ui/widgets/common/item_popupmenu_filter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../common/enums/sort_direction_type.dart';
import '../../../common/styles.dart';
import '../common/bottom_sheet_title.dart';
import '../common/modal_sheet_separator.dart';
import '../common/sort_direction_popupmenu_filter.dart';

class ArtifactBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ModalSheetSeparator(),
            BottomSheetTitle(icon: Icons.playlist_play, title: 'Filters'),
            Text('Rarity'),
            Center(
              child: SmoothStarRating(
                allowHalfRating: false,
                onRated: (v) {},
                starCount: 5,
                size: 35.0,
                color: Colors.yellow,
                borderColor: Colors.yellow,
                spacing: 0.0,
              ),
            ),
            Text('Others'),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ItemPopupMenuFilter<ArtifactFilterType>(
                  tooltipText: 'Sort by',
                  onSelected: (v) => {},
                  selectedValue: ArtifactFilterType.name,
                  values: ArtifactFilterType.values,
                ),
                SortDirectionPopupMenuFilter(
                  selectedSortDirection: SortDirectionType.asc,
                  onSelected: (v) => {},
                )
              ],
            ),
            ButtonBar(
              buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
              children: <Widget>[
                OutlineButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.primaryColor)),
                ),
                RaisedButton(
                  color: theme.primaryColor,
                  onPressed: () => {},
                  child: Text('Ok'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
