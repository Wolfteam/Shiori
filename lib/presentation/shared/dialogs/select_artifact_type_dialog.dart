import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/artifact_image_type.dart';

class SelectArtifactTypeDialog extends StatefulWidget {
  final List<ArtifactType> excluded;

  const SelectArtifactTypeDialog({
    Key? key,
    this.excluded = const <ArtifactType>[],
  }) : super(key: key);

  @override
  _SelectArtifactTypeDialogState createState() => _SelectArtifactTypeDialogState();
}

class _SelectArtifactTypeDialogState extends State<SelectArtifactTypeDialog> {
  ArtifactType? currentSelectedType;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    const values = ArtifactType.values;
    if (widget.excluded.isNotEmpty) {
      values.removeWhere((el) => widget.excluded.contains(el));
    }

    return AlertDialog(
      title: Text(s.type),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        height: mq.getHeightForDialogs(values.length),
        child: ListView.builder(
          itemCount: values.length,
          itemBuilder: (ctx, index) {
            final type = values[index];
            //For some reason I need to wrap this thing on a material to avoid this problem
            // https://stackoverflow.com/questions/67912387/scrollable-listview-bleeds-background-color-to-adjacent-widgets
            return Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key('$index'),
                leading: ArtifactImageType.fromType(type: type),
                title: Text(
                  s.translateArtifactType(type),
                  overflow: TextOverflow.ellipsis,
                ),
                selected: currentSelectedType == type,
                selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                onTap: () {
                  setState(() {
                    currentSelectedType = type;
                  });
                },
              ),
            );
          },
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop<ArtifactType>(context, currentSelectedType),
          child: Text(s.ok),
        )
      ],
    );
  }
}
