import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/bottom_sheet_title.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';

class RightBottomSheet extends StatelessWidget {
  final List<Widget> children;
  final Widget bottom;
  final IconData icon;
  final String? title;

  const RightBottomSheet({
    Key? key,
    required this.children,
    required this.bottom,
    this.icon = GenshinDb.filter,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final filterTitle = title ?? s.filters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BottomSheetTitle(
                  icon: icon,
                  title: filterTitle,
                ),
                ...children,
              ],
            ),
          ),
        ),
        Divider(color: Theme.of(context).primaryColor),
        bottom,
      ],
    );
  }
}
