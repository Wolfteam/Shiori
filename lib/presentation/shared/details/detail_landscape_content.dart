import 'package:flutter/material.dart';

class DetailLandscapeContent extends StatelessWidget {
  final Color color;
  final List<String> tabs;
  final List<Widget> children;
  final EdgeInsets padding;

  const DetailLandscapeContent({
    super.key,
    required this.color,
    required this.tabs,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 25),
  });

  DetailLandscapeContent.noTabs({
    required this.color,
    required Widget child,
    this.padding = const EdgeInsets.symmetric(horizontal: 25),
  })  : children = [child],
        tabs = [];

  @override
  Widget build(BuildContext context) {
    if (children.length == 1) {
      return Container(
        color: color,
        padding: const EdgeInsets.only(right: 40),
        child: Scaffold(
          body: Padding(
            padding: padding,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: children.first,
            ),
          ),
        ),
      );
    }

    final tabColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    return DefaultTabController(
      length: tabs.length,
      //had to use a container to keep the background color on the system bar
      child: Container(
        color: color,
        padding: const EdgeInsets.only(right: 40),
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.pink,
              shadowColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: TabBar(
                physics: const BouncingScrollPhysics(),
                indicatorColor: color,
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 30),
                labelColor: tabColor,
                tabs: tabs.map((e) => Tab(text: e)).toList(),
              ),
            ),
            body: Padding(
              padding: padding,
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
