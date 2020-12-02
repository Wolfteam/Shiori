import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../common/enums/character_filter_type.dart';
import '../../../common/enums/released_unreleased_type.dart';
import '../../../common/enums/sort_direction_type.dart';
import '../../../common/styles.dart';
import '../common/bottom_sheet_title.dart';
import '../common/elements_button_bar.dart';
import '../common/item_popupmenu_filter.dart';
import '../common/modal_sheet_separator.dart';
import '../common/sort_direction_popupmenu_filter.dart';
import '../common/weapons_button_bar.dart';

class CharacterBottomSheet extends StatelessWidget {
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
            Text('Elements'),
            ElementsButtonBar(),
            Text('Weapons'),
            WeaponsButtonBar(),
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
                ItemPopupMenuFilter<ReleasedUnreleasedType>(
                  tooltipText: 'Released / Unreleased type',
                  values: ReleasedUnreleasedType.values,
                  selectedValue: ReleasedUnreleasedType.all,
                  onSelected: (v) => {},
                  icon: const Icon(Icons.all_inbox),
                ),
                ItemPopupMenuFilter<CharacterFilterType>(
                  tooltipText: 'Sort By',
                  values: CharacterFilterType.values,
                  selectedValue: CharacterFilterType.name,
                  onSelected: (v) => {},
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
