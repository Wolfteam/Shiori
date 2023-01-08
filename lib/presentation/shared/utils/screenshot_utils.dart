import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/utils/permission_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

typedef OnError = void Function(Object ex, StackTrace trace);

class ScreenshotUtils {
  static Future<bool> takeScreenshot(ScreenshotController controller, BuildContext context) async {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    try {
      if (!await PermissionUtils.isStoragePermissionGranted()) {
        ToastUtils.showInfoToast(fToast, s.acceptToSaveImg);
        return false;
      }

      final bytes = await controller.capture(pixelRatio: 1.5);
      await ImageGallerySaver.saveImage(bytes!, quality: 100);
      ToastUtils.showSucceedToast(fToast, s.imgSavedSuccessfully);
      return true;
    } catch (e) {
      ToastUtils.showErrorToast(fToast, s.unknownError);
      rethrow;
    }
  }
}
