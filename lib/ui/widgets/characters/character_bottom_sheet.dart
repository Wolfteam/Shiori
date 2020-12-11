import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../common/enums/character_filter_type.dart';
import '../../../common/enums/released_unreleased_type.dart';
import '../../../common/enums/sort_direction_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
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
    final s = S.of(context);

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
            BottomSheetTitle(icon: Icons.playlist_play, title: s.filters),
            Text(s.elements),
            ElementsButtonBar(),
            Text(s.weapons),
            WeaponsButtonBar(),
            Text(s.rarity),
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
            Text(s.others),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ItemPopupMenuFilter<ReleasedUnreleasedType>(
                  tooltipText: '${s.released} / ${s.unreleased}',
                  values: ReleasedUnreleasedType.values,
                  selectedValue: ReleasedUnreleasedType.all,
                  onSelected: (v) => {},
                  icon: const Icon(Icons.all_inbox),
                  itemText: (val) => s.translateReleasedUnreleasedType(val),
                ),
                ItemPopupMenuFilter<CharacterFilterType>(
                  tooltipText: s.sortBy,
                  values: CharacterFilterType.values,
                  selectedValue: CharacterFilterType.name,
                  onSelected: (v) => {},
                  itemText: (val) => s.translateCharacterFilterType(val),
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
                  child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                ),
                RaisedButton(
                  color: theme.primaryColor,
                  onPressed: () => {},
                  child: Text(s.ok),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
