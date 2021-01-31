import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/character/character_page.dart';

class CircleCharacter extends StatelessWidget {
  final String image;

  const CircleCharacter({
    Key key,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
        onTap: () => _gotoCharacterPage(image, context),
        child: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage(image),
        ),
      ),
    );
  }

  Future<void> _gotoCharacterPage(String image, BuildContext context) async {
    context.read<CharacterBloc>().add(CharacterEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => const CharacterPage());
    await Navigator.push(context, route);
  }
}
