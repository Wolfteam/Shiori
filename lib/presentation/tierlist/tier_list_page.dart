import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';
import 'package:screenshot/screenshot.dart';

class TierListPage extends StatefulWidget {
  @override
  _TierListPageState createState() => _TierListPageState();
}

class _TierListPageState extends State<TierListPage> {
  final screenshotController = ScreenshotController();
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tier List'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: () {
          _imageFile = null;
          screenshotController.capture(pixelRatio: 1.5).then((File image) {
            //Capture Done
            setState(() {
              _imageFile = image;
            });
          }).catchError((onError) {
            print(onError);
          });
        })],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        onPressed: () {

        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  if (_imageFile != null) Text('Image captured start********'),
                  if (_imageFile != null) Image.file(_imageFile),
                  if (_imageFile != null) Text('Image captured end********'),
                  TierListRow(
                    title: 'S',
                    color: Colors.red,
                    images: [
                      Assets.getCharacterPath('Keqing.png'),
                      Assets.getCharacterPath('Klee.png'),
                      Assets.getCharacterPath('Diluc.png'),
                      Assets.getCharacterPath('Keqing.png'),
                      Assets.getCharacterPath('Klee.png'),
                    ],
                  ),
                  TierListRow(
                    title: 'A',
                    color: Colors.orange,
                    images: [
                      Assets.getCharacterPath('Jean.png'),
                      Assets.getCharacterPath('Albedo.png'),
                      Assets.getCharacterPath('Jean.png'),
                      Assets.getCharacterPath('Albedo.png'),
                      Assets.getCharacterPath('Jean.png'),
                      Assets.getCharacterPath('Albedo.png'),
                    ],
                  ),
                  TierListRow(
                    title: 'B',
                    color: Colors.yellow,
                    images: [
                      Assets.getCharacterPath('Barbara.png'),
                      Assets.getCharacterPath('Kaeya.png'),
                    ],
                  ),
                  TierListRow(
                    title: 'C',
                    color: Colors.greenAccent,
                    images: [
                      Assets.getCharacterPath('Lisa.png'),
                      Assets.getCharacterPath('Noelle.png'),
                    ],
                  ),
                  TierListRow(
                    title: 'D',
                    color: Colors.green,
                    images: [
                      Assets.getCharacterPath('Amber.png'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TierListRow extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> images;

  const TierListRow({
    Key key,
    @required this.title,
    @required this.color,
    @required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 20,
                child: Container(
                  color: color,
                  child: Center(child: Text(title, style: TextStyle(color: Colors.black))),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 70,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: images.map((e) => CircleCharacter(image: e)).toList(),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down),
                      onPressed: () {},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
