import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:shiori/presentation/tierlist/widgets/tierlist_fab.dart';
import 'package:shiori/presentation/tierlist/widgets/tierlist_row.dart';

class TierListPage extends StatefulWidget {
  @override
  _TierListPageState createState() => _TierListPageState();
}

class _TierListPageState extends State<TierListPage> {
  final screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    const double fabHeight = 100;
    return BlocProvider<TierListBloc>(
      create: (ctx) => Injection.tierListBloc..add(const TierListEvent.init()),
      child: Scaffold(
        appBar: _AppBar(screenshotController: screenshotController),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const TierListFab(height: fabHeight),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Screenshot(
              controller: screenshotController,
              child: BlocBuilder<TierListBloc, TierListState>(
                builder: (ctx, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...state.rows.mapIndex(
                      (e, index) => TierListRow(
                        index: index,
                        title: e.tierText,
                        color: Color(e.tierColor),
                        items: e.items,
                        isUpButtonEnabled: index != 0,
                        isDownButtonEnabled: index != state.rows.length - 1,
                        numberOfRows: state.rows.length,
                        showButtons: !state.readyToSave,
                        isTheLastRow: state.rows.length == 1,
                      ),
                    ),
                    if (!state.readyToSave && state.charsAvailable.isNotEmpty)
                      SizedBox.fromSize(
                        size: const Size.fromHeight(fabHeight),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final ScreenshotController screenshotController;

  const _AppBar({required this.screenshotController});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<TierListBloc, TierListState>(
      builder: (ctx, state) => AppBar(
        title: Text(s.tierListBuilder),
        actions: [
          if (!state.readyToSave)
            Tooltip(
              message: s.confirm,
              child: IconButton(
                splashRadius: Styles.mediumButtonSplashRadius,
                icon: const Icon(Icons.check),
                onPressed: () => ctx.read<TierListBloc>().add(const TierListEvent.readyToSave(ready: true)),
              ),
            ),
          if (!state.readyToSave)
            Tooltip(
              message: s.clearAll,
              child: IconButton(
                splashRadius: Styles.mediumButtonSplashRadius,
                icon: const Icon(Icons.clear_all),
                onPressed: () => context.read<TierListBloc>().add(const TierListEvent.clearAllRows()),
              ),
            ),
          if (!state.readyToSave)
            Tooltip(
              message: s.restore,
              child: IconButton(
                splashRadius: Styles.mediumButtonSplashRadius,
                icon: const Icon(Icons.settings_backup_restore_sharp),
                onPressed: () => context.read<TierListBloc>().add(const TierListEvent.init(reset: true)),
              ),
            ),
          if (state.readyToSave)
            Tooltip(
              message: s.save,
              child: IconButton(
                splashRadius: Styles.mediumButtonSplashRadius,
                icon: const Icon(Icons.save_alt),
                onPressed: () => _takeScreenshot(context),
              ),
            ),
          if (state.readyToSave)
            Tooltip(
              message: s.cancel,
              child: IconButton(
                splashRadius: Styles.mediumButtonSplashRadius,
                icon: const Icon(Icons.undo),
                onPressed: () => context.read<TierListBloc>().add(const TierListEvent.readyToSave(ready: false)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _takeScreenshot(BuildContext context) async {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    final bloc = context.read<TierListBloc>();
    try {
      if (!await Permission.storage.request().isGranted) {
        ToastUtils.showInfoToast(fToast, s.acceptToSaveImg);
        return;
      }

      final bytes = await screenshotController.capture(pixelRatio: 1.5);
      await ImageGallerySaver.saveImage(bytes!, quality: 100);
      ToastUtils.showSucceedToast(fToast, s.imgSavedSuccessfully);
      bloc.add(const TierListEvent.screenshotTaken(succeed: true));
    } catch (e, trace) {
      ToastUtils.showErrorToast(fToast, s.unknownError);
      bloc.add(TierListEvent.screenshotTaken(succeed: false, ex: e, trace: trace));
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
