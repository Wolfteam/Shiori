import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/sliver_loading.dart';
import 'package:genshindb/presentation/today_materials/widgets/sliver_weapon_ascension_materials.dart';

class SliverTodayWeaponMaterials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverLoading(),
          loaded: (_, weaponAscMaterials) => SliverWeaponAscensionMaterials(weaponAscMaterials: weaponAscMaterials),
        );
      },
    );
  }
}
