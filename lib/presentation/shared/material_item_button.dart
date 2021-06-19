import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/material/material_page.dart' as mp;

class MaterialItemButton extends StatelessWidget {
  final String image;
  final double size;

  const MaterialItemButton({
    Key? key,
    required this.image,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      iconSize: size,
      splashRadius: size * 0.6,
      constraints: const BoxConstraints(),
      icon: Image.asset(image, width: size, height: size),
      onPressed: () => _gotoMaterialPage(context),
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    final bloc = context.read<MaterialBloc>();
    bloc.add(MaterialEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage());
    await Navigator.push(context, route);
    bloc.pop();
  }
}
