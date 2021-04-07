import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:genshindb/presentation/tierlist/widgets/tierlist_fab.dart';
import 'package:genshindb/presentation/tierlist/widgets/tierlist_row.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class TierListPage extends StatefulWidget {
  @override
  _TierListPageState createState() => _TierListPageState();
}

class _TierListPageState extends State<TierListPage> {
  final screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: BlocBuilder<TierListBloc, TierListState>(
          builder: (ctx, state) => AppBar(
            title: Text(s.tierListBuilder),
            actions: [
              if (!state.readyToSave)
                Tooltip(
                  message: s.confirm,
                  child: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => ctx.read<TierListBloc>().add(const TierListEvent.readyToSave(ready: true)),
                  ),
                ),
              if (!state.readyToSave)
                Tooltip(
                  message: s.clearAll,
                  child: IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () => context.read<TierListBloc>().add(const TierListEvent.clearAllRows()),
                  ),
                ),
              if (!state.readyToSave)
                Tooltip(
                  message: s.restore,
                  child: IconButton(
                    icon: const Icon(Icons.settings_backup_restore_sharp),
                    onPressed: () => context.read<TierListBloc>().add(const TierListEvent.init(reset: true)),
                  ),
                ),
              if (state.readyToSave)
                Tooltip(
                  message: s.save,
                  child: IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () => _takeScreenshot(),
                  ),
                ),
              if (state.readyToSave)
                Tooltip(
                  message: s.cancel,
                  child: IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () => context.read<TierListBloc>().add(const TierListEvent.readyToSave(ready: false)),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: TierListFab(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
            child: Screenshot(
              controller: screenshotController,
              child: BlocBuilder<TierListBloc, TierListState>(
                builder: (ctx, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: state.rows.mapIndex((e, index) => _buildTierRow(index, state.rows.length, state.readyToSave, e)).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierRow(int index, int totalNumberOfItems, bool readyToSave, TierListRowModel item) {
    return TierListRow(
      index: index,
      title: item.tierText,
      color: Color(item.tierColor),
      images: item.charImgs,
      isUpButtonEnabled: index != 0,
      isDownButtonEnabled: index != totalNumberOfItems - 1,
      numberOfRows: totalNumberOfItems,
      showButtons: !readyToSave,
      isTheLastRow: totalNumberOfItems == 1,
    );
  }

  Future<void> _takeScreenshot() async {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    final bloc = context.read<TierListBloc>();
    try {
      if (!await Permission.storage.request().isGranted) {
        ToastUtils.showInfoToast(fToast, s.acceptToSaveImg);
        return;
      }

      final bytes = await screenshotController.capture(pixelRatio: 1.5);
      ImageGallerySaver.saveImage(bytes, quality: 100);
      ToastUtils.showSucceedToast(fToast, s.imgSavedSuccessfully);
      bloc.add(const TierListEvent.screenshotTaken(succeed: true));
    } catch (e, trace) {
      ToastUtils.showErrorToast(fToast, s.unknownError);
      bloc.add(TierListEvent.screenshotTaken(succeed: false, ex: e, trace: trace));
    }
  }
}
