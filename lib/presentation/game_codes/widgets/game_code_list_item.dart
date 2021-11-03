import 'package:flutter/cupertino.dart';
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
import 'package:shiori/presentation/shared/images/wrapped_ascension_material.dart';
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
    Key? key,
    required GameCodeModel item,
  })  : code = item.code,
        discoveredOn = item.discoveredOn,
        expiredOn = item.expiredOn,
        isUsed = item.isUsed,
        isExpired = item.isExpired,
        region = item.region,
        rewards = item.rewards,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final textCodeStyle = !isUsed
        ? theme.textTheme.subtitle1
        : theme.textTheme.subtitle1!.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: theme.colorScheme.secondary,
            decorationThickness: 2,
          );

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: !isUsed ? s.markAsUsed : s.markAsUnused,
          color: !isUsed ? Colors.green : Colors.red,
          iconWidget: Icon(!isUsed ? Icons.check : Icons.close, color: Colors.white),
          onTap: () => context.read<GameCodesBloc>().add(GameCodesEvent.markAsUsed(code: code, wasUsed: !isUsed)),
        ),
        IconSlideAction(
          caption: s.copy,
          icon: Icons.copy,
          color: Colors.blueAccent,
          onTap: () => _copyToClipboard(context),
        ),
      ],
      child: InkWell(
        onTap: () => _copyToClipboard(context),
        child: Container(
          margin: Styles.edgeInsetVertical16,
          padding: Styles.edgeInsetHorizontal16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        code,
                        style: textCodeStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: rewards
                          .map(
                            (m) => WrappedAscensionMaterial(
                              itemKey: m.key,
                              image: m.image,
                              quantity: m.quantity,
                              size: SizeUtils.getSizeForCircleImages(context) * 0.6,
                            ),
                          )
                          .toList(),
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
                            style: theme.textTheme.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDateInfoRow(
                      s.addedOn(utils.DateUtils.formatDate(discoveredOn, format: utils.DateUtils.dayMonthYearFormat)),
                      context,
                    ),
                    if (isExpired)
                      _buildDateInfoRow(
                        s.expiredOn(utils.DateUtils.formatDate(expiredOn, format: utils.DateUtils.dayMonthYearFormat)),
                        context,
                      ),
                    if (!isExpired && expiredOn != null)
                      _buildDateInfoRow(
                        s.validUntil(utils.DateUtils.formatDate(expiredOn, format: utils.DateUtils.dayMonthYearFormat)),
                        context,
                      ),
                    if (!isExpired && expiredOn == null) _buildDateInfoRow(s.validUntil(s.na), context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfoRow(String text, BuildContext context) {
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
              style: theme.textTheme.caption,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final s = S.of(context);
    Clipboard.setData(ClipboardData(text: code)).then((value) => ToastUtils.showInfoToast(ToastUtils.of(context), s.codeXWasCopied(code)));
  }
}
