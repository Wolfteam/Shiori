import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/weapon/weapon_page.dart';

import 'circle_item.dart';

class CircleWeapon extends StatelessWidget {
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String) onTap;

  const CircleWeapon({
    Key key,
    @required this.image,
    this.radius = 30,
    this.forDrag = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleItem(
      image: image,
      radius: radius,
      forDrag: forDrag,
      onTap: (img) => onTap != null ? onTap(img) : _gotoWeaponPage(context),
    );
  }

  Future<void> _gotoWeaponPage(BuildContext context) async {
    final bloc = context.read<WeaponBloc>();
    bloc.add(WeaponEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => WeaponPage());
    await Navigator.push(context, route);
    await route.completed;
    bloc.pop();
  }
}
