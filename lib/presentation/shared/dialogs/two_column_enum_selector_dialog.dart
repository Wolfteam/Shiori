import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

typedef _OnOk<TEnum> = void Function(List<TEnum> selected);
//TODO: PROPER NAME FOR THIS WIDGET

class TwoColumnEnumSelectorDialog<TEnum> extends StatefulWidget {
  final String title;
  final String leftTitle;
  final String rightTitle;
  final String nothingSelectedMsg;
  final List<TranslatedEnum<TEnum>> all;
  final List<TranslatedEnum<TEnum>> selectedStats;
  final int maxNumberOfSelections;
  final _OnOk<TEnum> onOk;
  final bool showMaxNumberOfSelectionsOnTitle;

  const TwoColumnEnumSelectorDialog({
    super.key,
    required this.title,
    required this.leftTitle,
    required this.rightTitle,
    required this.nothingSelectedMsg,
    required this.all,
    required this.selectedStats,
    required this.maxNumberOfSelections,
    required this.onOk,
    this.showMaxNumberOfSelectionsOnTitle = true,
  })  : assert(all.length > 0),
        assert(maxNumberOfSelections > 0);

  @override
  State<TwoColumnEnumSelectorDialog> createState() => _TwoColumnEnumSelectorDialogState<TEnum>();
}

class _TwoColumnEnumSelectorDialogState<TEnum> extends State<TwoColumnEnumSelectorDialog<TEnum>> {
  late ScrollController _rightController;
  late ScrollController _leftController;

  List<TranslatedEnum<TEnum>> _all = [];
  List<TranslatedEnum<TEnum>> _selected = [];
  TranslatedEnum<TEnum>? _selectedRight;
  TranslatedEnum<TEnum>? _selectedLeft;

  @override
  void initState() {
    _all = [...widget.all];
    _selected = [...widget.selectedStats];
    _all.removeWhere((el) => _selected.contains(el));

    _rightController = ScrollController();
    _leftController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final deviceType = getDeviceType(mq.size);
    bool useRow = true;
    if (deviceType == DeviceScreenType.mobile && mq.orientation == Orientation.portrait) {
      useRow = false;
    }
    final dialogHeight = mq.getHeightForDialogs(_all.length + _selected.length, maxHeight: 400);
    final dialogWidth = mq.getWidthForDialogs();
    final bgColor = theme.brightness == Brightness.dark
        ? (theme.scaffoldBackgroundColor == Colors.black ? theme.cardColor : theme.colorScheme.background.withOpacity(0.8))
        : theme.dividerColor;
    final canAddMoreItems = _selected.length == widget.maxNumberOfSelections;
    return AlertDialog(
      title: useRow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.title),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.leftTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.rightTitle} (${_selected.length} / ${widget.maxNumberOfSelections})',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Text(widget.title),
      content: SizedBox(
        height: dialogHeight,
        child: useRow
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      width: dialogWidth,
                      color: bgColor,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _all.length,
                        controller: _leftController,
                        itemBuilder: (ctx, index) {
                          final item = _all[index];
                          return Material(
                            key: Key('$index-selected'),
                            color: Colors.transparent,
                            child: ListTile(
                              key: Key('$index-all'),
                              title: Text(item.translation, overflow: TextOverflow.ellipsis),
                              selected: _selectedLeft == item,
                              selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                              onTap: () => _onItemTap(item, true),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _Buttons<TEnum>(
                    useRow: false,
                    onLeftTap: _selectedRight == null ? null : () => _handleLeftButtonClick(),
                    onRightTap: _selectedLeft == null || canAddMoreItems ? null : () => _handleRightButtonClick(),
                  ),
                  Expanded(
                    child: _selected.isNotEmpty
                        ? Container(
                            width: dialogWidth,
                            color: bgColor,
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              itemCount: _selected.length,
                              scrollController: _rightController,
                              itemBuilder: (ctx, index) {
                                final item = _selected[index];
                                return Material(
                                  key: Key('$index-selected'),
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(item.translation, overflow: TextOverflow.ellipsis),
                                    selected: _selectedRight == item,
                                    selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                                    onTap: () => _onItemTap(item, false),
                                  ),
                                );
                              },
                              onReorder: _onReorder,
                            ),
                          )
                        : NothingFoundColumn(msg: widget.nothingSelectedMsg),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.leftTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: dialogHeight / 3,
                    width: double.maxFinite,
                    color: bgColor,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _all.length,
                      controller: _leftController,
                      itemBuilder: (ctx, index) {
                        final item = _all[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            key: Key('$index-all'),
                            title: Text(item.translation, overflow: TextOverflow.ellipsis),
                            selected: _selectedLeft == item,
                            selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                            onTap: () => _onItemTap(item, true),
                          ),
                        );
                      },
                    ),
                  ),
                  _Buttons<TEnum>(
                    useRow: true,
                    onLeftTap: _selectedRight == null ? null : () => _handleLeftButtonClick(),
                    onRightTap: _selectedLeft == null || canAddMoreItems ? null : () => _handleRightButtonClick(),
                  ),
                  Text(
                    '${widget.rightTitle} (${_selected.length} / ${widget.maxNumberOfSelections})',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      height: dialogHeight / 3,
                      width: double.maxFinite,
                      color: bgColor,
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: _selected.length,
                        scrollController: _rightController,
                        itemBuilder: (ctx, index) {
                          final item = _selected[index];
                          return Material(
                            key: Key('$index-selected'),
                            color: Colors.transparent,
                            child: ListTile(
                              title: Text(item.translation, overflow: TextOverflow.ellipsis),
                              selected: _selectedRight == item,
                              selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                              onTap: () => _onItemTap(item, false),
                            ),
                          );
                        },
                        onReorder: _onReorder,
                      ),
                    )
                  else
                    NothingFoundColumn(msg: widget.nothingSelectedMsg),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.onOk(_selected.map((e) => e.enumValue).toList());
            Navigator.pop(context);
          },
          child: Text(s.ok),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    final item = _selected.elementAt(oldIndex);
    int updatedNewIndex = newIndex;
    if (updatedNewIndex >= _selected.length || updatedNewIndex > 0) {
      updatedNewIndex--;
    }
    if (updatedNewIndex < 0) {
      updatedNewIndex = 0;
    }
    setState(() {
      _selected.removeAt(oldIndex);
      _selected.insert(updatedNewIndex, item);
    });
  }

  void _onItemTap(TranslatedEnum<TEnum> item, bool leftWasTapped) {
    TranslatedEnum<TEnum>? newValue;
    if (!leftWasTapped && _selectedRight != item) {
      newValue = item;
    } else if (leftWasTapped && _selectedLeft != item) {
      newValue = item;
    }

    setState(() {
      if (leftWasTapped) {
        _selectedLeft = newValue;
      } else {
        _selectedRight = newValue;
      }
    });
  }

  void _handleLeftButtonClick() => _handleButtonClick(_all, _selected, _selectedRight, true);

  void _handleRightButtonClick() => _handleButtonClick(_selected, _all, _selectedLeft, false);

  void _handleButtonClick(
    List<TranslatedEnum<TEnum>> addTo,
    List<TranslatedEnum<TEnum>> removeFrom,
    TranslatedEnum<TEnum>? selected,
    bool leftWasClicked,
  ) {
    if (selected == null) {
      return;
    }

    if (!addTo.contains(selected)) {
      addTo.add(selected);
    }

    removeFrom.removeWhere((el) => el == selected);
    setState(() {
      if (leftWasClicked) {
        _selectedRight = null;
        addTo.sort((x, y) => x.translation.compareTo(y.translation));
      } else {
        _selectedLeft = null;
      }
    });
  }
}

class _Buttons<TEnum> extends StatelessWidget {
  final bool useRow;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;

  const _Buttons({
    super.key,
    required this.useRow,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    final leftButton = IconButton(
      splashRadius: Styles.smallButtonSplashRadius,
      icon: Icon(!useRow ? Icons.chevron_left : Icons.keyboard_arrow_up),
      onPressed: onLeftTap != null ? () => onLeftTap!() : null,
    );
    final rightButton = IconButton(
      splashRadius: Styles.smallButtonSplashRadius,
      icon: Icon(!useRow ? Icons.chevron_right : Icons.keyboard_arrow_down),
      onPressed: onRightTap != null ? () => onRightTap!() : null,
    );
    return useRow
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leftButton,
              rightButton,
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leftButton,
              rightButton,
            ],
          );
  }
}
