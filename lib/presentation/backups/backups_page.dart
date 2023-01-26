import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/backups/widgets/backup_list_item.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class BackupsPage extends StatefulWidget {
  const BackupsPage({super.key});

  @override
  State<BackupsPage> createState() => _BackupsPageState();
}

class _BackupsPageState extends State<BackupsPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider<BackupRestoreBloc>(
      create: (context) => Injection.backupRestoreBloc..add(const BackupRestoreEvent.init()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Backups'),
          actions: [
            BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
              builder: (context, state) => state.maybeMap(loaded: (_) => false, orElse: () => true)
                  ? const SizedBox.shrink()
                  : Tooltip(
                      message: 'Import',
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Icons.upload),
                        onPressed: () => FilePicker.platform
                            .pickFiles(dialogTitle: 'Choose a file', lockParentWindow: true)
                            .then((result) => _handlePickerResult(context, result)),
                      ),
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<BackupRestoreBloc, BackupRestoreState>(
            listener: (context, state) {
              state.maybeMap(
                loaded: (state) {
                  if (state.createResult != null) {
                    _handleCreateResult(context, state.createResult);
                  } else if (state.restoreResult != null) {
                    _handleRestoreResult(context, state.restoreResult);
                  } else if (state.readResult != null) {
                    _handleReadResult(context, state.readResult);
                  }
                },
                orElse: () {},
              );
            },
            builder: (context, state) => state.maybeMap(
              loaded: (state) => state.backups.isEmpty
                  ? const NothingFoundColumn()
                  : ListView.builder(
                      itemCount: state.backups.length,
                      itemBuilder: (context, index) => BackupListItem(backup: state.backups[index]),
                    ),
              orElse: () => const Loading(useScaffold: false),
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => AppFab(
            icon: const Icon(Icons.add),
            hideFabAnimController: hideFabAnimController,
            scrollController: scrollController,
            mini: false,
            onPressed: () => showDialog<bool?>(
              context: context,
              builder: (context) => ConfirmDialog(
                title: s.confirm,
                content: 'Would you like to create a backup of all your data and configuration ?',
              ),
            ).then((confirmed) {
              if (confirmed == true) {
                context.read<BackupRestoreBloc>().add(const BackupRestoreEvent.create());
              }
            }),
          ),
        ),
      ),
    );
  }

  void _showToastMsg(String msg, bool succeed, BuildContext context) {
    final toast = ToastUtils.of(context);
    if (succeed) {
      ToastUtils.showSucceedToast(toast, msg);
    } else {
      ToastUtils.showErrorToast(toast, msg, durationType: ToastDurationType.long);
    }
  }

  void _handleCreateResult(BuildContext context, BackupOperationResultModel? result) {
    if (result == null) {
      return;
    }

    final s = S.of(context);
    final msg = result.succeed ? 'Backup = ${result.name} was successfully created' : 'Could not create backup';
    _showToastMsg(msg, result.succeed, context);
  }

  void _handleRestoreResult(BuildContext context, BackupOperationResultModel? result) {
    if (result == null) {
      return;
    }

    final s = S.of(context);
    final msg = result.succeed ? 'Backup = ${result.name} was successfully restored.\nRestarting...' : 'Could not restore file = ${result.name}';
    _showToastMsg(msg, result.succeed, context);
    if (result.succeed) {
      Future.delayed(const Duration(seconds: 1)).then((value) => context.read<MainBloc>().add(const MainEvent.restart()));
    }
  }

  void _handleReadResult(BuildContext context, BackupOperationResultModel? result) {
    if (result == null) {
      return;
    }

    final s = S.of(context);
    if (result.succeed) {
      showDialog<bool>(
        context: context,
        builder: (_) => ConfirmDialog(title: s.confirm, content: 'Would you like to restore backup = ${result.name} ?'),
      ).then((confirmed) {
        if (confirmed == true) {
          context.read<BackupRestoreBloc>().add(BackupRestoreEvent.restore(result.path));
        }
      });
    } else {
      _showToastMsg('File = ${result.name} could not be read.\nMake sure you have selected the appropriate one.', false, context);
    }
  }

  void _handlePickerResult(BuildContext context, FilePickerResult? result) {
    if (result == null) {
      return;
    }
    final path = result.files.single.path;
    if (path.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<BackupRestoreBloc>().add(BackupRestoreEvent.read(path!));
  }
}
