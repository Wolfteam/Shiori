import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/tierlist/widgets/rename_tierlist_dialog.dart';
import 'package:shiori/presentation/tierlist/widgets/tierlist_row_color_picker.dart';

enum TierListRowOptionsType {
  addRowAbove,
  addRowBelow,
  rename,
  delete,
  clear,
  changeColor,
}

class TierListRow extends StatelessWidget {
  final int index;
  final String title;
  final Color color;
  final List<ItemCommon> items;
  final bool showButtons;
  final bool isUpButtonEnabled;
  final bool isDownButtonEnabled;
  final int numberOfRows;
  final bool isTheLastRow;

  const TierListRow({
    super.key,
    required this.index,
    required this.title,
    required this.color,
    required this.items,
    required this.numberOfRows,
    required this.isTheLastRow,
    this.showButtons = true,
    this.isUpButtonEnabled = true,
    this.isDownButtonEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final width = MediaQuery.of(context).size.width;
    var flexA = 25;
    var flexB = showButtons ? 65 : 75;
    var flexC = 10;
    if (width > 1200) {
      flexA = 20;
      flexB = showButtons ? 70 : 80;
      flexC = 10;
    }

    return DragTarget<ItemCommon>(
      builder: (BuildContext context, List<ItemCommon?> incoming, List<dynamic> rejected) => Column(
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: flexA,
                  child: Container(
                    color: color,
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: flexB,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: items
                        .map(
                          (e) => CircleCharacter(
                            itemKey: e.key,
                            image: e.image,
                            radius: SizeUtils.getSizeForCircleImages(context),
                            onTap: (img) => context.read<TierListBloc>().add(TierListEvent.deleteCharacterFromRow(index: index, item: e)),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (showButtons)
                  Flexible(
                    fit: FlexFit.tight,
                    flex: flexC,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up),
                          splashRadius: Styles.smallButtonSplashRadius,
                          onPressed: isUpButtonEnabled
                              ? () => context.read<TierListBloc>().add(TierListEvent.rowPositionChanged(index: index, newIndex: index - 1))
                              : null,
                        ),
                        PopupMenuButton<TierListRowOptionsType>(
                          onSelected: (result) => _onRowOptionSelected(context, result),
                          icon: const Icon(Icons.settings),
                          tooltip: s.rowSettings,
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<TierListRowOptionsType>>[
                            PopupMenuItem<TierListRowOptionsType>(
                              value: TierListRowOptionsType.addRowAbove,
                              child: _buildOption(Icons.add, s.addRowAbove),
                            ),
                            PopupMenuItem<TierListRowOptionsType>(
                              value: TierListRowOptionsType.addRowBelow,
                              child: _buildOption(Icons.add, s.addRowBelow),
                            ),
                            PopupMenuItem<TierListRowOptionsType>(
                              value: TierListRowOptionsType.rename,
                              child: _buildOption(Icons.edit, s.rename),
                            ),
                            if (!isTheLastRow)
                              PopupMenuItem<TierListRowOptionsType>(
                                value: TierListRowOptionsType.delete,
                                child: _buildOption(Icons.delete, s.deleteRow),
                              ),
                            if (items.isNotEmpty)
                              PopupMenuItem<TierListRowOptionsType>(
                                value: TierListRowOptionsType.clear,
                                child: _buildOption(Icons.clear_all, s.clearRow),
                              ),
                            PopupMenuItem<TierListRowOptionsType>(
                              value: TierListRowOptionsType.changeColor,
                              child: _buildOption(Icons.color_lens_outlined, s.changeColor),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          splashRadius: Styles.smallButtonSplashRadius,
                          onPressed: isDownButtonEnabled
                              ? () => context.read<TierListBloc>().add(TierListEvent.rowPositionChanged(index: index, newIndex: index + 1))
                              : null,
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
      onAccept: (item) => context.read<TierListBloc>().add(TierListEvent.addCharacterToRow(index: index, item: item)),
    );
  }

  Widget _buildOption(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        Container(margin: const EdgeInsets.only(left: 10), child: Text(text)),
      ],
    );
  }

  Future<void> _onRowOptionSelected(BuildContext context, TierListRowOptionsType optionType) async {
    switch (optionType) {
      case TierListRowOptionsType.addRowAbove:
        context.read<TierListBloc>().add(TierListEvent.addNewRow(index: index, above: true));
        break;
      case TierListRowOptionsType.addRowBelow:
        context.read<TierListBloc>().add(TierListEvent.addNewRow(index: index, above: false));
        break;
      case TierListRowOptionsType.rename:
        _showRenameDialog(context);
        break;
      case TierListRowOptionsType.delete:
        context.read<TierListBloc>().add(TierListEvent.deleteRow(index: index));
        break;
      case TierListRowOptionsType.clear:
        context.read<TierListBloc>().add(TierListEvent.clearRow(index: index));
        break;
      case TierListRowOptionsType.changeColor:
        await _showColorPicker(context);
        break;
    }
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (_) => BlocProvider.value(
        value: context.read<TierListBloc>(),
        child: RenameTierListRowDialog(
          title: title,
          index: index,
        ),
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    final bloc = context.read<TierListBloc>();
    final newColor = await showDialog<Color>(
      context: context,
      builder: (_) => TierListRowColorPicker(currentColor: color),
    );

    if (newColor != null && newColor != color) {
      bloc.add(TierListEvent.rowColorChanged(index: index, newColor: newColor.value));
    }
  }
}
