import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/utils/date_utils.dart' as utils;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/material_quantity_row.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class GameCodeListItem extends StatelessWidget {
  final String code;
  final DateTime? discoveredOn;
  final DateTime? expiredOn;
  final bool isUsed;
  final bool isExpired;
  final AppServerResetTimeType? region;

  final List<ItemAscensionMaterialModel> rewards;

  GameCodeListItem({
    super.key,
    required GameCodeModel item,
  })  : code = item.code,
        discoveredOn = item.discoveredOn,
        expiredOn = item.expiredOn,
        isUsed = item.isUsed,
        isExpired = item.isExpired,
        region = item.region,
        rewards = item.rewards;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final textCodeStyle = !isUsed
        ? theme.textTheme.titleMedium
        : theme.textTheme.titleMedium!.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: theme.colorScheme.primary,
            decorationThickness: 3,
          );
    final extentRatio = SizeUtils.getExtentRatioForSlidablePane(context);
    return Slidable(
      key: ValueKey(code),
      endActionPane: ActionPane(
        extentRatio: extentRatio,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            label: !isUsed ? s.markAsUsed : s.markAsUnused,
            backgroundColor: !isUsed ? Colors.green : Colors.red,
            icon: !isUsed ? Icons.check : Icons.close,
            onPressed: (_) => context.read<GameCodesBloc>().add(GameCodesEvent.markAsUsed(code: code, wasUsed: !isUsed)),
          ),
          SlidableAction(
            label: s.copy,
            icon: Icons.copy,
            backgroundColor: Colors.blueAccent,
            onPressed: (_) => _copyToClipboard(context),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _copyToClipboard(context),
        child: Container(
          margin: Styles.edgeInsetVertical16,
          padding: Styles.edgeInsetHorizontal16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          code,
                          style: textCodeStyle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: rewards.map((m) => MaterialQuantityRow.fromAscensionMaterial(item: m)).toList(),
                      ),
                      if (region != null)
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outlined,
                              color: theme.colorScheme.secondary,
                              size: SizeUtils.getSizeForCircleImages(context) * 0.45,
                            ),
                            Text(
                              s.onlyX(s.translateServerResetTimeType(region!)),
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DateRow(
                      text: s.addedOn(utils.DateUtils.formatDate(discoveredOn, format: utils.DateUtils.dayMonthYearFormat)),
                    ),
                    if (isExpired)
                      _DateRow(
                        text: s.expiredOn(utils.DateUtils.formatDate(expiredOn, format: utils.DateUtils.dayMonthYearFormat)),
                      ),
                    if (!isExpired && expiredOn != null)
                      _DateRow(
                        text: s.validUntil(utils.DateUtils.formatDate(expiredOn, format: utils.DateUtils.dayMonthYearFormat)),
                      ),
                    if (!isExpired && expiredOn == null) _DateRow(text: s.validUntil(s.na)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final s = S.of(context);
    Clipboard.setData(ClipboardData(text: code)).then((value) => ToastUtils.showInfoToast(ToastUtils.of(context), s.codeXWasCopied(code)));
  }
}

class _DateRow extends StatelessWidget {
  final String text;

  const _DateRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 5),
            child: const Icon(Icons.date_range, size: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
