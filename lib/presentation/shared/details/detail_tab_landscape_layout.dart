import 'package:flutter/material.dart';

class DetailTabLandscapeLayout extends StatelessWidget {
  final Color color;
  final List<String> tabs;
  final List<Widget> children;
  final EdgeInsets padding;

  const DetailTabLandscapeLayout({
    super.key,
    required this.color,
    required this.tabs,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 25),
  });

  @override
  Widget build(BuildContext context) {
    final tabColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    return DefaultTabController(
      length: tabs.length,
      //had to use a container to keep the background color on the system bar
      child: Container(
        color: color,
        padding: const EdgeInsets.only(right: 20),
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
