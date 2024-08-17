import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_common_with_name_appbar_search_delegate.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/wish_banner_history/wish_banner_history_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<BannerHistoryCountBloc, BannerHistoryCountState>(
      builder: (ctx, state) => AppBar(
        title: Text(s.bannerHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            splashRadius: Styles.mediumButtonSplashRadius,
            tooltip: s.search,
            onPressed: () => showSearch<List<String>>(
              context: context,
              delegate: ItemCommonWithNameAppBarSearchDelegate(
                ctx.read<BannerHistoryCountBloc>().getItemsForSearch(),
                [...state.selectedItemKeys],
              ),
            ).then((keys) {
              if (keys == null) {
                return;
              }
              context.read<BannerHistoryCountBloc>().add(BannerHistoryCountEvent.itemsSelected(keys: keys));
            }),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            splashRadius: Styles.mediumButtonSplashRadius,
            tooltip: s.bannerHistory,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishBannerHistoryPage())),
          ),
          ItemPopupMenuFilter<BannerHistoryItemType>(
            tooltipText: s.bannerType,
            selectedValue: state.type,
            values: BannerHistoryItemType.values,
            onSelected: (val) => context.read<BannerHistoryCountBloc>().add(BannerHistoryCountEvent.typeChanged(type: val)),
            icon: const Icon(Icons.swap_horiz),
            itemText: (val, _) => s.translateBannerHistoryItemType(val),
            splashRadius: Styles.mediumButtonSplashRadius,
          ),
          ItemPopupMenuFilter<BannerHistorySortType>(
            tooltipText: s.sortType,
            selectedValue: state.sortType,
            values: BannerHistorySortType.values,
            onSelected: (val) => context.read<BannerHistoryCountBloc>().add(BannerHistoryCountEvent.sortTypeChanged(type: val)),
            icon: const Icon(Icons.sort),
            itemText: (val, _) => s.translateBannerHistorySortType(val),
            splashRadius: Styles.mediumButtonSplashRadius,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
