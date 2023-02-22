import 'dart:io';

import 'package:darq/darq.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/backups/widgets/backup_data_types_selector_dialog.dart';
import 'package:shiori/presentation/backups/widgets/backup_list_item.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class BackupsPage extends StatelessWidget {
  const BackupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider<BackupRestoreBloc>(
      create: (context) => Injection.backupRestoreBloc..add(const BackupRestoreEvent.init()),
      child: Scaffold(
        appBar: AppBar(title: Text(s.backups)),
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
              loaded: (state) => ResponsiveBuilder(
                builder: (ctx, size) {
                  if (!isPortrait && size.screenSize.width > SizeUtils.minWidthOnDesktop) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 30,
                          child: SingleChildScrollView(
                            child: _Header(
                              backupCount: state.backups.length,
                              latestBackupDate: state.backups.firstOrDefault()?.createdAt,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 45,
                          child: CustomScrollView(
                            slivers: [
                              if (state.backups.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10, left: 16),
                                    child: Text(s.backups, style: theme.textTheme.titleLarge),
                                  ),
                                ),
                              if (state.backups.isNotEmpty)
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => BackupListItem(backup: state.backups[index]),
                                    childCount: state.backups.length,
                                  ),
                                ),
                              if (state.backups.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  fillOverscroll: true,
                                  child: NothingFoundColumn(),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(
                          backupCount: state.backups.length,
                          latestBackupDate: state.backups.firstOrDefault()?.createdAt,
                        ),
                      ),
                      if (state.backups.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            child: Text(s.backups, style: theme.textTheme.titleLarge),
                          ),
                        ),
                      if (state.backups.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => BackupListItem(backup: state.backups[index]),
                            childCount: state.backups.length,
                          ),
                        ),
                      if (state.backups.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          fillOverscroll: true,
                          child: NothingFoundColumn(),
                        ),
                    ],
                  );
                },
              ),
              orElse: () => const Loading(useScaffold: false),
            ),
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
    final msg = result.succeed ? s.backupWasCreated(result.filename) : s.couldNotCreateBackup;
    _showToastMsg(msg, result.succeed, context);
  }

  void _handleRestoreResult(BuildContext context, BackupOperationResultModel? result) {
    if (result == null) {
      return;
    }

    final s = S.of(context);
    final msg = result.succeed ? s.backupWasRestored(result.filename) : s.couldNotRestoreBackup;
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
      showDialog<List<AppBackupDataType>?>(
        context: context,
        builder: (_) => BackupDataTypesSelectorDialog(
          content: s.restoreBackupConfirmation(result.filename),
          dataTypes: result.dataTypes,
        ),
      ).then((dataTypes) {
        if (dataTypes?.isNotEmpty == true) {
          context.read<BackupRestoreBloc>().add(BackupRestoreEvent.restore(filePath: result.path, dataTypes: dataTypes!, imported: true));
        }
      });
    } else {
      _showToastMsg(s.fileCouldNotBeRead(result.filename), false, context);
    }
  }
}

class _Header extends StatelessWidget {
  final int backupCount;
  final DateTime? latestBackupDate;

  const _Header({
    required this.backupCount,
    this.latestBackupDate,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: Styles.edgeInsetAll15,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: Styles.edgeInsetAll5,
                  child: Icon(Icons.backup, size: 48, color: theme.primaryColor),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          s.lastBackup(
                            latestBackupDate == null ? s.na : DateFormat.yMd().add_Hm().format(latestBackupDate!),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s.totalX(backupCount),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Text(s.createBackupMsgInfoA),
            Text(s.createBackupMsgInfoB),
            Text(s.restoreBackupMsgWarning),
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () => showDialog<List<AppBackupDataType>?>(
                    context: context,
                    builder: (context) => BackupDataTypesSelectorDialog(
                      content: s.createBackupConfirmation,
                      dataTypes: AppBackupDataType.values,
                    ),
                  ).then((dataTypes) {
                    if (dataTypes?.isNotEmpty == true) {
                      context.read<BackupRestoreBloc>().add(BackupRestoreEvent.create(dataTypes: dataTypes!));
                    }
                  }),
                  child: Text(s.create),
                ),
                OutlinedButton(
                  onPressed: () => _pickFile(s, context),
                  child: Text(s.import),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(S s, BuildContext context) {
    final customFile = Platform.isWindows;
    return FilePicker.platform
        .pickFiles(
          dialogTitle: s.chooseFile,
          lockParentWindow: true,
          type: customFile ? FileType.custom : FileType.any,
          allowedExtensions: customFile ? [backupFileExtension.replaceAll('.', '')] : null,
        )
        .then((result) => _handlePickerResult(context, result));
  }

  void _handlePickerResult(BuildContext context, FilePickerResult? result) {
    if (result == null) {
      return;
    }
    final path = result.files.single.path;
    if (path.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<BackupRestoreBloc>().add(BackupRestoreEvent.read(filePath: path!));
  }
}
