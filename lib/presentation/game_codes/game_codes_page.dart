import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_table_cell.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:genshindb/presentation/shared/wrapped_ascension_material.dart';
import 'package:url_launcher/url_launcher.dart';

class GameCodesPage extends StatelessWidget {
  const GameCodesPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.gameCodes),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl('https://genshin.mihoyo.com/en/gift'),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: Styles.edgeInsetAll10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<GameCodesBloc, GameCodesState>(
                  builder: (ctx, state) => state.map(
                    loaded: (state) => _buildTableCard(s.workingCodes, state.workingGameCodes, context),
                  ),
                ),
                BlocBuilder<GameCodesBloc, GameCodesState>(
                  builder: (ctx, state) => state.map(
                    loaded: (state) => _buildTableCard(s.expiredCodes, state.expiredGameCodes, context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(String title, List<GameCodeModel> codes, BuildContext context) {
    final s = S.of(context);
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll5,
        child: Table(
          columnWidths: const {
            0: FractionColumnWidth(.25),
            1: FractionColumnWidth(.45),
            2: FractionColumnWidth(.25),
          },
          children: [
            TableRow(
              children: [
                CommonTableCell(text: s.codes, padding: Styles.edgeInsetAll10),
                CommonTableCell(text: s.rewards, padding: Styles.edgeInsetAll10),
                Container(),
              ],
            ),
            ...codes.map((e) => _buildRow(s, context, e)).toList(),
          ],
        ),
      ),
    );

    return ItemDescriptionDetail(
      title: title,
      body: body,
      textColor: Theme.of(context).accentColor,
    );
  }

  TableRow _buildRow(S s, BuildContext context, GameCodeModel model) {
    final rewards = model.rewards.map((m) => WrappedAscensionMaterial(image: m.fullImagePath, quantity: m.quantity, size: 20)).toList();
    return TableRow(
      children: [
        CommonTableCell.child(
          child: Center(
            child: Tooltip(
              message: model.code,
              child: Text(
                model.code,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        CommonTableCell.child(
          child: Wrap(alignment: WrapAlignment.center, children: rewards),
        ),
        CommonTableCell.child(
          child: Wrap(
            alignment: WrapAlignment.end,
            children: [
              IconButton(
                tooltip: !model.isUsed ? s.markAsUsed : s.markAsUnused,
                splashRadius: 20,
                icon: Icon(Icons.check, color: model.isUsed ? Colors.green : Colors.red),
                onPressed: () => context.read<GameCodesBloc>().add(GameCodesEvent.markAsUsed(code: model.code, wasUsed: !model.isUsed)),
              ),
              IconButton(
                tooltip: s.copy,
                splashRadius: 20,
                icon: const Icon(Icons.copy),
                onPressed: () => Clipboard.setData(ClipboardData(text: model.code)).then(
                  (value) => ToastUtils.showInfoToast(s.codeXWasCopied(model.code)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
