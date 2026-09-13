import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

//Owns the export logs bloc and its delivery logic, handing the child a callback to trigger the export.
//
//On macOS and Windows this shows a save dialog so the user picks a real destination, since the
//export otherwise lands in the app's sandbox container. Mobile keeps the share sheet, which is the
//idiomatic mechanism there. Nothing is shown while the export runs since it completes in milliseconds;
//failures surface as a toast.
class ExportLogsWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, VoidCallback onExport) builder;

  const ExportLogsWrapper({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider<ExportLogsBloc>(
      create: (context) => Injection.exportLogsBloc,
      child: BlocListener<ExportLogsBloc, ExportLogsState>(
        listener: (context, state) async {
          switch (state) {
            case ExportLogsStateSucceed():
              await _deliver(context, state.file, s);
            case ExportLogsStateFailed():
              ToastUtils.showWarningToast(ToastUtils.of(context), s.logsExportFailed);
            case ExportLogsStateLoading():
              break;
          }
        },
        child: Builder(
          builder: (context) => builder(
            context,
            () => context.read<ExportLogsBloc>().add(const ExportLogsEvent.export()),
          ),
        ),
      ),
    );
  }

  Future<void> _deliver(BuildContext context, File file, S s) async {
    //On desktop the export otherwise lands in the sandbox container, which a user cannot navigate to
    if (Platform.isMacOS || Platform.isWindows) {
      final String? savePath = await FilePicker.saveFile(
        dialogTitle: s.exportLogs,
        fileName: p.basename(file.path),
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (savePath == null) {
        //The user cancelled the save dialog; that is not an error
        return;
      }
      await file.copy(savePath);
      return;
    }

    await _share(context, file, s);
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
