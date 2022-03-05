import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/dialogs/text_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class DonationsBottomSheet extends StatelessWidget {
  const DonationsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (ctx) => Injection.donationsBloc..add(const DonationsEvent.init()),
      child: CommonBottomSheet(
        titleIcon: Shiori.heart,
        title: s.donations,
        showCancelButton: false,
        showOkButton: false,
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  PackageItemModel? _selected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocConsumer<DonationsBloc, DonationsState>(
      listener: (ctx, state) {
        state.maybeMap(
          purchaseCompleted: (state) => _handlePurchaseOrRestoreCompleted(true, state.error, context),
          restoreCompleted: (state) => _handlePurchaseOrRestoreCompleted(false, state.error, context),
          orElse: () {},
        );
      },
      builder: (ctx, state) => state.maybeMap(
        initial: (state) => state.noInternetConnection || !state.isInitialized || !state.canMakePurchases
            ? _Error(noInternetConnection: state.noInternetConnection, isInitialized: state.isInitialized, canMakePurchases: state.canMakePurchases)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    s.donationMsg,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ...state.packages.map(
                    (e) => _DonationItem(
                      item: e,
                      isSelected: _selected == e,
                      onTap: () => setState(() => _selected = e),
                    ),
                  ),
                  CommonButtonBar(
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                      ),
                      if (state.packages.isNotEmpty && state.isInitialized)
                        OutlinedButton(
                          onPressed: () => _handleRestore(context),
                          child: Text(s.restorePurchases, style: TextStyle(color: theme.primaryColor)),
                        ),
                      if (state.packages.isNotEmpty && state.isInitialized && _selected != null)
                        ElevatedButton(
                          onPressed: () => _handleConfirm(context),
                          child: Text(s.confirm),
                        )
                    ],
                  ),
                ],
              ),
        orElse: () => const Loading(useScaffold: false),
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context) {
    final s = S.of(context);
    return showDialog(
      context: context,
      builder: (_) => TextDialog.create(
        title: s.purchase,
        hintText: s.userId,
        maxLength: DonationsBloc.maxUserIdLength,
        regexPattern: DonationsBloc.appUserIdRegex,
        child: BulletList(
          iconSize: 16,
          addTooltip: false,
          items: [s.purchaseMsgA, s.purchaseMsgB],
        ),
        onSave: (val) => context
            .read<DonationsBloc>()
            .add(DonationsEvent.purchase(userId: val, identifier: _selected!.identifier, offeringIdentifier: _selected!.offeringIdentifier)),
      ),
    );
  }

  Future<void> _handleRestore(BuildContext context) {
    final s = S.of(context);
    return showDialog(
      context: context,
      builder: (_) => TextDialog.create(
        title: s.restorePurchases,
        hintText: s.userId,
        maxLength: DonationsBloc.maxUserIdLength,
        regexPattern: DonationsBloc.appUserIdRegex,
        child: BulletList(
          iconSize: 16,
          addTooltip: false,
          items: [s.restorePurchaseMsgA],
        ),
        onSave: (val) => context.read<DonationsBloc>().add(DonationsEvent.restorePurchases(userId: val)),
      ),
    );
  }

  void _handlePurchaseOrRestoreCompleted(bool isPurchase, bool error, BuildContext context) {
    final s = S.of(context);
    final toast = ToastUtils.of(context);
    String msg = '';
    if (isPurchase) {
      msg = error ? s.paymentError : s.paymentSucceed;
    } else {
      msg = error ? s.restorePurchaseError : s.restorePurchaseSucceed;
    }

    if (!error) {
      ToastUtils.showSucceedToast(toast, msg);
      Navigator.pop(context);
    } else {
      ToastUtils.showWarningToast(toast, msg);
    }
  }
}

class _DonationItem extends StatelessWidget {
  final PackageItemModel item;
  final bool isSelected;
  final GestureTapCallback onTap;

  const _DonationItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Card(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.5) : null,
        margin: Styles.edgeInsetAll10,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Text(
            s.donateXAmount(item.priceString),
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle1,
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final bool noInternetConnection;
  final bool isInitialized;
  final bool canMakePurchases;

  const _Error({
    Key? key,
    required this.noInternetConnection,
    required this.isInitialized,
    required this.canMakePurchases,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final msg = noInternetConnection
        ? s.noInternetConnection
        : !canMakePurchases
            ? 'Device cannot make purchases'
            : s.unknownError;
    return NothingFoundColumn(msg: msg);
  }
}