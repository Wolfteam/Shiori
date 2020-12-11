import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class ItemExpansionPanel extends StatelessWidget {
  final String title;
  final Widget body;
  final Icon icon;

  const ItemExpansionPanel({
    Key key,
    @required this.title,
    @required this.body,
    this.icon = const Icon(Icons.settings),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll10,
      child: ExpansionPanelList(
        dividerColor: Colors.red,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          // setState(() {
          //   _data[index].isExpanded = !isExpanded;
          // });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 10),
                leading: icon,
                title: Transform.translate(
                  offset: Styles.listItemWithIconOffset,
                  child: Tooltip(
                    message: title,
                    child: Text(
                      title,
                      style: theme.textTheme.headline6.copyWith(color: theme.accentColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
            body: body,
            isExpanded: true,
          )
        ],
      ),
    );
  }
}
