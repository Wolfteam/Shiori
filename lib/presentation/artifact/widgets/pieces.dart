part of '../artifact_page.dart';

class _Pieces extends StatelessWidget {
  final Color color;
  final List<String> pieces;

  const _Pieces({
    required this.color,
    required this.pieces,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = SizeUtils.getSizeForSquareImages(context);
    return DetailSection.complex(
      title: s.pieces,
      color: color,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: pieces
              .map(
                (e) => Container(
                  margin: Styles.edgeInsetAll5,
                  child: Image.file(File(e), width: size.width, height: size.height),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
