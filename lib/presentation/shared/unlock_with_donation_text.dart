import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/donations/donations_bottom_sheet.dart';
import 'package:shiori/presentation/shared/styles.dart';

class UnlockWithDonationText extends StatelessWidget {
  const UnlockWithDonationText({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: Styles.modalBottomSheetShape,
        isDismissible: true,
        isScrollControlled: true,
        builder: (ctx) => const DonationsBottomSheet(),
      ),
      child: Text(
        s.unlockedWithDonation,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: theme.textTheme.caption!.copyWith(color: theme.primaryColor, fontStyle: FontStyle.italic),
      ),
    );
  }
}
