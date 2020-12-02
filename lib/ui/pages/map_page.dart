import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  final String script = '''
    let elements = document.getElementsByClassName("nav-link");
    let total = elements.length;
    for (let index = 0; index < total; index++) {
        const element = elements[index];
        const text = element.childNodes[0].textContent;
        if (text !== "Markers") {
            element.remove();
            total--;
            index--;
        }

        if (total === 1)
            break;
    }
    document.getElementsByClassName("fixed-bottom")[0].remove();
    ''';

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        if (state.type == WebViewState.finishLoad) {
          print("loaded...");
          _onPageLoaded();
        } else if (state.type == WebViewState.abortLoad) {
          // if there is a problem with loading the url
          print("there is a problem...");
        } else if (state.type == WebViewState.startLoad) {
          // if the url started loading
          print("start loading...");
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebviewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: "https://genshin-impact-map.appsample.com/#/",
      hidden: true,
      clearCache: true,
      clearCookies: true,
    );
  }

  Rect _buildRect() {
    final statusBarHeight = 24;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final top = topPadding;
    var height = mediaQuery.size.height - top;
    height -= 56.0 + mediaQuery.padding.bottom;

    if (height < 0.0) {
      height = 0.0;
    }

    return new Rect.fromLTWH(0.0, top + statusBarHeight, mediaQuery.size.width, height - statusBarHeight);
  }

  void _onPageLoaded() {
    flutterWebviewPlugin.resize(_buildRect());
    flutterWebviewPlugin.evalJavascript(script);
  }
}
