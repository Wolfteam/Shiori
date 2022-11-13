import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/styles.dart';

typedef SearchChanged = void Function(String val);

class SearchBox extends StatefulWidget {
  final String? value;
  final bool showClearButton;
  final SearchChanged searchChanged;

  const SearchBox({
    super.key,
    this.value,
    required this.searchChanged,
    this.showClearButton = true,
  });

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final _searchFocusNode = FocusNode();
  late String? _currentValue;
  late TextEditingController _searchBoxTextController;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value ?? '';
    _searchBoxTextController = TextEditingController(text: widget.value);
    _searchBoxTextController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _searchBoxTextController.removeListener(_onSearchTextChanged);
    _searchBoxTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final maxWidth = MediaQuery.of(context).size.width;
    final device = getDeviceType(MediaQuery.of(context).size);
    final maxSize = device == DeviceScreenType.mobile && isPortrait ? maxWidth : maxWidth * 0.7;

    return Container(
      constraints: BoxConstraints(maxWidth: maxSize),
      child: Card(
        elevation: 3,
        margin: Styles.edgeInsetAll10,
        child: Row(
          children: <Widget>[
            IconButton(
              splashRadius: Styles.smallButtonSplashRadius,
              onPressed: () => _searchFocusNode.requestFocus(),
              icon: const Icon(Icons.search),
            ),
            Expanded(
              child: TextField(
                controller: _searchBoxTextController,
                focusNode: _searchFocusNode,
                cursorColor: theme.colorScheme.secondary,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  hintText: '${s.search}...',
                ),
              ),
            ),
            if (widget.showClearButton)
              IconButton(
                icon: const Icon(Icons.close),
                splashRadius: Styles.smallButtonSplashRadius,
                onPressed: _cleanSearchText,
              ),
          ],
        ),
      ),
    );
  }

  void _onSearchTextChanged() {
    //Focusing the text field triggers text changed, that why we used it like this
    if (_currentValue == _searchBoxTextController.text) {
      return;
    }
    _currentValue = _searchBoxTextController.text;
    widget.searchChanged(_searchBoxTextController.text);
  }

  void _cleanSearchText() {
    _searchFocusNode.requestFocus();
    if (_searchBoxTextController.text.isEmpty) {
      return;
    }
    _searchBoxTextController.text = '';
  }
}
