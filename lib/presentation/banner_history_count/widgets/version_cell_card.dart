import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/shared/dialogs/banner_version_history_dialog.dart';
import 'package:shiori/presentation/shared/styles.dart';

class VersionCellCard extends StatelessWidget {
  final double version;
  final bool isSelected;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const VersionCellCard({
    required this.version,
    required this.isSelected,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);
    return Container(
      margin: Styles.edgeInsetVertical5,
      child: InkWell(
        onTap: () => context.read<BannerHistoryCountBloc>().add(BannerHistoryCountEvent.versionSelected(version: version)),
        onLongPress: () => showDialog(context: context, builder: (_) => BannerVersionHistoryDialog(version: version)),
        borderRadius: borderRadius,
        child: Card(
          margin: margin,
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.45) : theme.colorScheme.primaryContainer,
          elevation: isSelected ? 0 : null,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Center(
            child: Text(
              '$version',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
