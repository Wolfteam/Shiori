import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/character_filter_type.dart';
import '../../../common/enums/item_status_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/genshin_db_icons.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/bottom_sheet_title.dart';
import '../common/elements_button_bar.dart';
import '../common/item_popupmenu_filter.dart';
import '../common/loading.dart';
import '../common/modal_sheet_separator.dart';
import '../common/rarity_rating.dart';
import '../common/sort_direction_popupmenu_filter.dart';
import '../common/weapons_button_bar.dart';

class CharacterBottomSheet extends StatelessWidget {
  const CharacterBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<CharactersBloc, CharactersState>(
          builder: (context, state) {
            return state.map(
              loading: (_) => const Loading(),
              loaded: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ModalSheetSeparator(),
                  BottomSheetTitle(icon: GenshinDb.filter, title: s.filters),
                  Text(s.elements),
                  ElementsButtonBar(
                    selectedValues: state.tempElementTypes,
                    onClick: (v) => context.read<CharactersBloc>().add(CharactersEvent.elementTypeChanged(v)),
                  ),
                  Text(s.weapons),
                  WeaponsButtonBar(
                    selectedValues: state.tempWeaponTypes,
                    onClick: (v) => context.read<CharactersBloc>().add(CharactersEvent.weaponTypeChanged(v)),
                  ),
                  Text(s.rarity),
                  RarityRating(
                    rarity: state.rarity,
                    onRated: (v) => context.read<CharactersBloc>().add(CharactersEvent.rarityChanged(v)),
                  ),
                  Text(s.others),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ItemPopupMenuFilter<ItemStatusType>(
                        tooltipText: '${s.released} / ${s.brandNew} / ${s.comingSoon}',
                        values: ItemStatusType.values,
                        selectedValue: state.tempStatusType,
                        onSelected: (v) => context.read<CharactersBloc>().add(CharactersEvent.itemStatusChanged(v)),
                        icon: const Icon(GenshinDb.sliders_h, size: 18),
                        itemText: (val) => s.translateReleasedUnreleasedType(val),
                      ),
                      ItemPopupMenuFilter<CharacterFilterType>(
                        tooltipText: s.sortBy,
                        values: CharacterFilterType.values,
                        selectedValue: state.tempCharacterFilterType,
                        onSelected: (v) =>
                            context.read<CharactersBloc>().add(CharactersEvent.characterFilterTypeChanged(v)),
                        itemText: (val) => s.translateCharacterFilterType(val),
                      ),
                      SortDirectionPopupMenuFilter(
                        selectedSortDirection: state.tempSortDirectionType,
                        onSelected: (v) =>
                            context.read<CharactersBloc>().add(CharactersEvent.sortDirectionTypeChanged(v)),
                      )
                    ],
                  ),
                  ButtonBar(
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                    children: <Widget>[
                      OutlineButton(
                        onPressed: () {
                          context.read<CharactersBloc>().add(const CharactersEvent.cancelChanges());
                          Navigator.pop(context);
                        },
                        child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                      ),
                      RaisedButton(
                        color: theme.primaryColor,
                        onPressed: () {
                          context.read<CharactersBloc>().add(const CharactersEvent.applyFilterChanges());
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
