import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bullet_list.dart';

class InfoDialog extends StatelessWidget {
  final List<String> explanations;

  const InfoDialog({
    Key key,
    @required this.explanations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.information),
      content: SingleChildScrollView(
        child: BulletList(items: explanations, fontSize: 14),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.ok),
        )
      ],
    );
  }
}
