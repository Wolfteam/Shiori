import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class DonationsBottomSheet extends StatelessWidget {
  const DonationsBottomSheet({super.key});

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
  const _Body();

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  PackageItemModel? _selected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
            ? _Error(
                noInternetConnection: state.noInternetConnection,
                isInitialized: state.isInitialized,
                canMakePurchases: state.canMakePurchases,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    s.donationMsg,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
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
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(s.cancel),
                      ),
                      if (state.packages.isNotEmpty && state.isInitialized)
                        TextButton(
                          onPressed: () => context.read<DonationsBloc>().add(const DonationsEvent.restorePurchases()),
                          child: Text(s.restorePurchases),
                        ),
                      if (state.packages.isNotEmpty && state.isInitialized && _selected != null)
                        FilledButton(
                          onPressed: () => context.read<DonationsBloc>().add(
                            DonationsEvent.purchase(
                              identifier: _selected!.identifier,
                              offeringIdentifier: _selected!.offeringIdentifier,
                            ),
                          ),
                          child: Text(s.confirm),
                        ),
                    ],
                  ),
                ],
              ),
        orElse: () => const Loading(useScaffold: false),
      ),
    );
  }

  void _handlePurchaseOrRestoreCompleted(bool isPurchase, bool error, BuildContext context) {
    final s = S.of(context);
    final toast = ToastUtils.of(context);
    String msg = '';
    if (isPurchase) {
      msg = error ? s.paymentError : '${s.paymentSucceed}\n${s.restartMayBeNeeded}';
    } else {
      msg = error ? s.restorePurchaseError : '${s.restorePurchaseSucceed}\n${s.restartMayBeNeeded}';
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
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.5)
            : theme.scaffoldBackgroundColor == Colors.black
            ? theme.cardColor.withValues(alpha: 0.5)
            : theme.cardColor,
        margin: Styles.edgeInsetAll10,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Text(
            s.donateXAmount(item.priceString),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
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
    required this.noInternetConnection,
    required this.isInitialized,
    required this.canMakePurchases,
  });

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
