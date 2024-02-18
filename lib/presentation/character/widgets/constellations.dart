part of '../character_page.dart';

class _Constellations extends StatefulWidget {
  final Color color;
  final List<CharacterConstellationModel> constellations;
  final bool expanded;

  const _Constellations({
    required this.color,
    required this.constellations,
    this.expanded = false,
  });

  @override
  State<_Constellations> createState() => _ConstellationsState();
}

class _ConstellationsState extends State<_Constellations> {
  final List<bool> _isOpen = [];

  @override
  void initState() {
    _isOpen.clear();
    _isOpen.addAll(List.generate(widget.constellations.length, (index) => widget.expanded));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.constellations,
      color: widget.color,
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isOpen) => setState(() {
            _isOpen[index] = isOpen;
          }),
          dividerColor: Colors.transparent,
          elevation: 0,
          expandIconColor: widget.color,
          expandedHeaderPadding: EdgeInsets.zero,
          materialGapSize: 5,
          children: widget.constellations
              .mapIndex(
                (e, i) => ExpansionPanel(
                  isExpanded: _isOpen[i],
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) => _ConstellationTile(color: widget.color, title: e.title, image: e.image, number: e.number),
                  body: _ConstellationBody(color: widget.color, model: e),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ConstellationTile extends StatelessWidget {
  final Color color;
  final String title;
  final String image;
  final int number;

  const _ConstellationTile({
    required this.color,
    required this.title,
    required this.image,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    const double iconSize = 50;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Padding(
          padding: Styles.edgeInsetAll5,
          child: ClipOval(
            child: image == Assets.noImageAvailablePath
                ? Image.asset(image, width: iconSize, height: iconSize, fit: BoxFit.cover)
                : Image.file(File(image), width: iconSize, fit: BoxFit.cover),
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(s.constellationX('$number')),
      horizontalTitleGap: 5,
      iconColor: color,
      minVerticalPadding: 0,
      subtitleTextStyle: theme.textTheme.bodyMedium!.copyWith(color: color),
    );
  }
}

class _ConstellationBody extends StatelessWidget {
  final Color color;
  final CharacterConstellationModel model;

  const _ConstellationBody({
    required this.color,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Styles.edgeInsetHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomDivider.zeroIndent(color: color, drawShape: false),
          Text(
            model.description.removeLineBreakAtEnd()!,
          ),
          if (model.descriptions.isNotEmpty)
            BulletList(
              items: model.descriptions,
              addTooltip: false,
            ),
          if (model.secondDescription.isNotNullEmptyOrWhitespace)
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                model.secondDescription.removeLineBreakAtEnd()!,
              ),
            ),
          CustomDivider.zeroIndent(color: color, drawShape: false),
        ],
      ),
    );
  }
}
