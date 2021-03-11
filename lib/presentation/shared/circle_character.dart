import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/character/character_page.dart';

class CircleCharacter extends StatelessWidget {
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String) onTap;

  const CircleCharacter({
    Key key,
    @required this.image,
    this.radius = 35,
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
    if (forDrag) {
      return avatar;
    }

    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onTap != null ? onTap(image) : _gotoCharacterPage(image, context),
        child: avatar,
      ),
    );
  }

  Future<void> _gotoCharacterPage(String image, BuildContext context) async {
    final bloc = context.read<CharacterBloc>();
    bloc.add(CharacterEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => const CharacterPage());
    await Navigator.push(context, route);
    bloc.pop();
  }
}
