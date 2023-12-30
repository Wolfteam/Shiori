import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';

class ChangeCurrentDayDialog extends StatefulWidget {
  final int currentSelectedDay;

  const ChangeCurrentDayDialog({
    super.key,
    required this.currentSelectedDay,
  });

  @override
  _ChangeCurrentDayDialogState createState() => _ChangeCurrentDayDialogState();
}

class _ChangeCurrentDayDialogState extends State<ChangeCurrentDayDialog> {
  late int currentSelectedDay;

  @override
  void initState() {
    currentSelectedDay = widget.currentSelectedDay;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
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
        width: mq.getWidthForDialogs(),
        height: mq.getHeightForDialogs(days.length),
        child: ListView.builder(
          itemCount: days.entries.length,
          itemBuilder: (ctx, index) {
            final day = days.entries.elementAt(index);
            //For some reason I need to wrap this thing on a material to avoid this problem
            // https://stackoverflow.com/questions/67912387/scrollable-listview-bleeds-background-color-to-adjacent-widgets
            return Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key('$index'),
                title: Text(day.value, overflow: TextOverflow.ellipsis),
                selected: currentSelectedDay == day.key,
                selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                onTap: () {
                  setState(() {
                    currentSelectedDay = day.key;
                  });
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        TextButton(
          onPressed: () => Navigator.pop<int>(context, -1),
          child: Text(s.restore, style: TextStyle(color: theme.primaryColor)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop<int>(context, currentSelectedDay),
          child: Text(s.ok),
        ),
      ],
    );
  }
}
