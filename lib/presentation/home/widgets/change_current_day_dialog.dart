import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';

class ChangeCurrentDayDialog extends StatefulWidget {
  final int currentSelectedDay;

  const ChangeCurrentDayDialog({
    Key key,
    @required this.currentSelectedDay,
  }) : super(key: key);

  @override
  _ChangeCurrentDayDialogState createState() => _ChangeCurrentDayDialogState();
}

class _ChangeCurrentDayDialogState extends State<ChangeCurrentDayDialog> {
  int currentSelectedDay;

  @override
  void initState() {
    currentSelectedDay = widget.currentSelectedDay;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final days = <int, String>{
      DateTime.monday: s.monday,
      DateTime.tuesday: s.tuesday,
      DateTime.wednesday: s.wednesday,
      DateTime.thursday: s.thursday,
      DateTime.friday: s.friday,
      DateTime.saturday: s.saturday,
      DateTime.sunday: s.sunday,
    };

    return AlertDialog(
      title: Text(s.day),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: days.entries.length,
          itemBuilder: (ctx, index) {
            final day = days.entries.elementAt(index);
            return ListTile(
              key: Key('$index'),
              title: Text(day.value, overflow: TextOverflow.ellipsis),
              selected: currentSelectedDay == day.key,
              selectedTileColor: theme.accentColor.withOpacity(0.2),
              onTap: () {
                setState(() {
                  currentSelectedDay = day.key;
                });
              },
            );
          },
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop<int>(context, -1),
          child: Text(s.restore, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop<int>(context, currentSelectedDay),
          child: Text(s.ok),
        )
      ],
    );
  }
}
