import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/weapon/weapon_page.dart';

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
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(image),
    );

    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onTap != null ? onTap(image) : _gotoWeaponPage(image, context),
        child: avatar,
      ),
    );
  }

  Future<void> _gotoWeaponPage(String image, BuildContext context) async {
    context.read<WeaponBloc>().add(WeaponEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => WeaponPage());
    await Navigator.push(context, route);
  }
}
