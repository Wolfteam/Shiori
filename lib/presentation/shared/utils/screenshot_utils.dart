import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/utils/permission_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

typedef OnError = void Function(Object ex, StackTrace trace);

class ScreenshotUtils {
  static Future<bool> takeScreenshot(ScreenshotController controller, BuildContext context) async {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    const double pixelRatio = 1.5;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (!await PermissionUtils.isStoragePermissionGranted()) {
          ToastUtils.showInfoToast(fToast, s.acceptToSaveImg);
          return false;
        }

        final bytes = await controller.capture(pixelRatio: pixelRatio);
        await ImageGallerySaverPlus.saveImage(bytes!, quality: 100);
        ToastUtils.showSucceedToast(fToast, s.imgSavedSuccessfully);
      } else {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String? path = await controller.captureAndSave(appDocDir.path, pixelRatio: pixelRatio);
        if (!path.isNullEmptyOrWhitespace) {
          await OpenFile.open(path);
        }
      }
      return true;
    } catch (e) {
      ToastUtils.showErrorToast(fToast, s.unknownError);
      rethrow;
    }
  }
}
