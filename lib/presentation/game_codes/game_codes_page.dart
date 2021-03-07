import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_table_cell.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:genshindb/presentation/shared/wrapped_ascension_material.dart';

class GameCodesPage extends StatelessWidget {
  const GameCodesPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.gameCodes)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: Styles.edgeInsetAll10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<GameCodesBloc, GameCodesState>(
                  builder: (ctx, state) => state.map(
                    loading: (_) => const Loading(useScaffold: false),
                    loaded: (state) => _buildTableCard(s.workingCodes, state.workingGameCodes, context),
                  ),
                ),
                BlocBuilder<GameCodesBloc, GameCodesState>(
                  builder: (ctx, state) => state.map(
                    loading: (_) => const Loading(useScaffold: false),
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

  Widget _buildTableCard(String title, List<GameCodeFileModel> codes, BuildContext context) {
    final s = S.of(context);
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetVertical5,
        child: Table(
          columnWidths: const {
            0: FractionColumnWidth(.35),
            1: FractionColumnWidth(.5),
            2: FractionColumnWidth(.15),
          },
          children: [
            TableRow(
              children: [
                CommonTableCell(text: s.codes, padding: Styles.edgeInsetAll10),
                CommonTableCell(text: s.rewards, padding: Styles.edgeInsetAll10),
                Container(),
              ],
            ),
            ...codes.map((e) => _buildRow(s, e)).toList(),
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

  TableRow _buildRow(S s, GameCodeFileModel model) {
    final rewards = model.rewards.map((m) => WrappedAscensionMaterial(image: m.fullImagePath, quantity: m.quantity)).toList();
    return TableRow(
      children: [
        CommonTableCell.child(
          padding: Styles.edgeInsetAll10,
          child: Center(child: Tooltip(message: model.code, child: Text(model.code, overflow: TextOverflow.ellipsis))),
        ),
        CommonTableCell.child(
          padding: Styles.edgeInsetAll5,
          child: Wrap(alignment: WrapAlignment.center, children: rewards),
        ),
        CommonTableCell.child(
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.copy),
            onPressed: () => Clipboard.setData(ClipboardData(text: model.code)).then(
              (value) => ToastUtils.showInfoToast(s.codeXWasCopied(model.code)),
            ),
          ),
        ),
      ],
    );
  }
}
