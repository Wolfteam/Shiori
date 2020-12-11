import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../common/enums/sort_direction_type.dart';
import '../../../common/enums/weapon_filter_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/bottom_sheet_title.dart';
import '../common/item_popupmenu_filter.dart';
import '../common/modal_sheet_separator.dart';
import '../common/sort_direction_popupmenu_filter.dart';
import '../common/weapons_button_bar.dart';

class WeaponBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
            BottomSheetTitle(icon: Icons.playlist_play, title: s.filters),
            // Text('Elements'),
            // ElementsButtonBar(),
            Text(s.type),
            WeaponsButtonBar(),
            Text(s.rarity),
            Center(
              child: SmoothStarRating(
                allowHalfRating: false,
                onRated: (v) {},
                size: 35.0,
                color: Colors.yellow,
                borderColor: Colors.yellow,
              ),
            ),
            Text(s.others),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ItemPopupMenuFilter<WeaponFilterType>(
                  tooltipText: s.sortBy,
                  onSelected: (v) => {},
                  selectedValue: WeaponFilterType.name,
                  values: WeaponFilterType.values,
                  itemText: (val) => s.translateWeaponFilterType(val),
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
