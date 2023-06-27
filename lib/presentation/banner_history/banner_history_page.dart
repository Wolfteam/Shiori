import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/banner_history/widgets/grouped_banner_period.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_common_with_name_appbar_search_delegate.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';

class WishBannerHistoryPage extends StatelessWidget {
  final bool forSelection;

  const WishBannerHistoryPage({
    super.key,
    this.forSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider<WishBannerHistoryBloc>(
      create: (context) => Injection.wishBannerHistoryBloc..add(const WishBannerHistoryEvent.init()),
      child: BlocBuilder<WishBannerHistoryBloc, WishBannerHistoryState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(s.bannerHistory),
            actions: [
              state.map(
                loading: (_) => const SizedBox.shrink(),
                loaded: (state) => IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: s.search,
                  splashRadius: Styles.mediumButtonSplashRadius,
                  onPressed: () => showSearch<List<String>>(
                    context: context,
                    delegate: ItemCommonWithNameAppBarSearchDelegate.withNameOnly(
                      itemsWithNameOnly: context.read<WishBannerHistoryBloc>().getItemsForSearch(),
                      selected: [...state.selectedItemKeys],
                    ),
                  ).then((keys) {
                    if (keys == null) {
                      return;
                    }
                    context.read<WishBannerHistoryBloc>().add(WishBannerHistoryEvent.itemsSelected(keys: keys));
                  }),
                ),
              ),
              state.map(
                loading: (_) => const SizedBox.shrink(),
                loaded: (state) => ItemPopupMenuFilter<WishBannerGroupedType>(
                  tooltipText: s.groupBy,
                  splashRadius: Styles.mediumButtonSplashRadius,
                  values: WishBannerGroupedType.values,
                  selectedValue: state.groupedType,
                  onSelected: (v) => context.read<WishBannerHistoryBloc>().add(WishBannerHistoryEvent.groupTypeChanged(v)),
                  itemText: (val, _) => s.translateWishBannerGroupedType(val),
                  icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(false, true)),
                ),
              ),
              state.map(
                loading: (_) => const SizedBox.shrink(),
                loaded: (state) => SortDirectionPopupMenuFilter(
                  selectedSortDirection: state.sortDirectionType,
                  splashRadius: Styles.mediumButtonSplashRadius,
                  onSelected: (v) => context.read<WishBannerHistoryBloc>().add(WishBannerHistoryEvent.sortDirectionTypeChanged(v)),
                  icon: Icon(Icons.sort, size: Styles.getIconSizeForItemPopupMenuFilter(false, true)),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => ListView.builder(
                itemCount: state.filteredPeriods.length,
                itemBuilder: (context, index) => BannerGroupedPeriod(
                  group: state.filteredPeriods[index],
                  forSelection: forSelection,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
