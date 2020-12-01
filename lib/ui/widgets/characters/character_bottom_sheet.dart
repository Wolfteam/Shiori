import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/weapon_type_extensions.dart';
import '../../../common/styles.dart';
import '../common/bottom_sheet_title.dart';
import '../common/modal_sheet_separator.dart';

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
            _buildElementsButtonBar(),
            Text('Weapons'),
            _buildWeaponButtonBar(),
            Text('All / Released / Unreleased'),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              overflowDirection: VerticalDirection.down,
              buttonPadding: EdgeInsets.all(0),
              children: [
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => {},
                  tooltip: 'Algo',
                ),
                IconButton(
                  icon: const Icon(Icons.attach_money),
                  onPressed: () => {},
                  tooltip: 'Algo',
                ),
                IconButton(
                  icon: const Icon(Icons.category),
                  onPressed: () => {},
                  tooltip: 'Algo',
                ),
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

  Widget _buildElementsButtonBar() {
    final buttons = ElementType.values
        .map((e) => IconButton(
              icon: Image.asset(e.getElementAsssetPath()),
              onPressed: () => {},
              tooltip: 'Algo',
            ))
        .toList();

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      overflowDirection: VerticalDirection.down,
      buttonPadding: EdgeInsets.all(0),
      children: buttons,
    );
  }

  Widget _buildWeaponButtonBar() {
    final buttons = WeaponType.values
        .map((e) => IconButton(
              // iconSize: 12,
              icon: Image.asset(e.getWeaponAssetPath()),
              onPressed: () => {},
              tooltip: 'Algo',
            ))
        .toList();

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      overflowDirection: VerticalDirection.down,
      buttonPadding: EdgeInsets.all(0),
      children: buttons,
    );
  }
}
