import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/select_enum_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/images/artifact_image_type.dart';

class SelectArtifactTypeDialog extends StatelessWidget {
  final List<ArtifactType> excluded;
  final List<ArtifactType> selectedValues;
  final Function(ArtifactType?)? onSave;

  const SelectArtifactTypeDialog({
    Key? key,
    this.excluded = const <ArtifactType>[],
    this.selectedValues = const <ArtifactType>[],
    this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SelectEnumDialog<ArtifactType>(
      title: s.type,
      values: ArtifactType.values.toList(),
      selectedValues: selectedValues,
      excluded: excluded,
      leadingIconResolver: (type, _) => ArtifactImageType.fromType(type: type),
      textResolver: (type) => s.translateArtifactType(type),
      lineThroughOnSelectedValues: true,
      onSave: (type) => _onSave(type, context),
    );
  }

  void _onSave(ArtifactType? type, BuildContext context) {
    onSave?.call(type);
    Navigator.pop<ArtifactType>(context, type);
  }
}
