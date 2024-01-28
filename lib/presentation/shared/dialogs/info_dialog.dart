import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';

class InfoDialog extends StatelessWidget {
  final List<String> explanations;

  const InfoDialog({
    super.key,
    required this.explanations,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.information),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).getWidthForDialogs(),
          child: BulletList(items: explanations, fontSize: 14),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.ok),
        ),
      ],
    );
  }
}
