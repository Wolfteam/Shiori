import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../../bloc/bloc.dart';
import '../../generated/l10n.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/page_message.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  final String script = '''
    setTimeout(function(){ 
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

        total = document.getElementsByClassName("fixed-bottom").length;
        for (let index = 0; index < total; index++) {
            if (document.getElementsByClassName("fixed-bottom").length > 0)
              document.getElementsByClassName("fixed-bottom")[0].remove();
        }
    }, 
    800);
    ''';

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        if (state.type == WebViewState.finishLoad) {
          debugPrint('loaded...');
          _onPageLoaded();
        } else if (state.type == WebViewState.abortLoad) {
          // if there is a problem with loading the url
          debugPrint('there is a problem...');
        } else if (state.type == WebViewState.startLoad) {
          // if the url started loading
          debugPrint('start loading...');
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: true, loadWishSimulator: false));
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebviewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<UrlPageBloc, UrlPageState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) {
            if (state.hasInternetConnection) {
              return WebviewScaffold(
                url: state.mapUrl,
                hidden: true,
                clearCache: true,
                clearCookies: true,
              );
            }
            return PageMessage(text: s.noInternetConnection);
          },
        );
      },
    );
  }

  Rect _buildRect() {
    const statusBarHeight = 24;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final top = topPadding;
    var height = mediaQuery.size.height - top;
    height -= 56.0 + mediaQuery.padding.bottom;

    if (height < 0.0) {
      height = 0.0;
    }

    return Rect.fromLTWH(0.0, top + statusBarHeight, mediaQuery.size.width, height - statusBarHeight);
  }

  void _onPageLoaded() {
    flutterWebviewPlugin.resize(_buildRect());
    flutterWebviewPlugin.evalJavascript(script);
  }
}
