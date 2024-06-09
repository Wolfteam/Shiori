import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/donations/donations_bottom_sheet.dart';
import 'package:shiori/presentation/shared/styles.dart';

class UnlockWithDonationText extends StatelessWidget {
  final bool canShowDonationDialog;
  const UnlockWithDonationText({super.key, required this.canShowDonationDialog});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: !canShowDonationDialog
          ? null
          : () => showModalBottomSheet(
                context: context,
                shape: Styles.modalBottomSheetShape,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (ctx) => const DonationsBottomSheet(),
              ),
      child: Text(
        s.unlockedWithDonation,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
      ),
    );
  }
}
