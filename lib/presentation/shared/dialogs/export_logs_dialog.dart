import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

//Builds the log export and hands it to the platform share sheet.
//
//The share sheet is used rather than a save dialog because macOS is sandboxed
//with read-only user-selected file access.
class ExportLogsDialog extends StatelessWidget {
  const ExportLogsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocProvider<ExportLogsBloc>(
      create: (context) => Injection.exportLogsBloc..add(const ExportLogsEvent.export()),
      child: BlocConsumer<ExportLogsBloc, ExportLogsState>(
        listener: (context, state) async {
          switch (state) {
            case ExportLogsStateSucceed():
              await _share(context, state.file, s);
              if (context.mounted) {
                Navigator.pop(context);
              }
            case ExportLogsStateFailed():
              ToastUtils.showWarningToast(ToastUtils.of(context), s.logsExportFailed);
              Navigator.pop(context);
            case ExportLogsStateLoading():
              break;
          }
        },
        builder: (context, state) => AlertDialog(
          title: Text(s.exportLogs),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.generatingLogsFile),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, File file, S s) {
    //The dialog's own box anchors the popover that iPad and macOS require
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final params = ShareParams(
      files: [XFile(file.path)],
      text: s.exportLogs,
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
    return SharePlus.instance.share(params);
  }
}
