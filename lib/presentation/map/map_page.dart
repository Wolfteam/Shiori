import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/page_message.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  final String script = '''
    let wasRemoved = false;
    function removeAds(){
      //console.log("Removing ads..");
      let topNav = document.getElementById("topnav");
      if (topNav) {
        topNav.remove();
      }

      let elements = document.getElementsByClassName("nav-link");
      let total = elements.length;
      for (let index = 0; index < total; index++) {
          const element = elements[index];
          if (index === 2 && !wasRemoved) {
              element.remove();
              wasRemoved = true;
          }
      }

      total = document.getElementsByClassName("fixed-bottom").length;
      for (let index = 0; index < total; index++) {
          if (document.getElementsByClassName("fixed-bottom").length > 0)
            document.getElementsByClassName("fixed-bottom")[0].remove();
      }
    }
    setTimeout(removeAds, 500);
    setTimeout(removeAds, 1000);
    setTimeout(removeAds, 2000);
    setTimeout(removeAds, 3500);
    ''';

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      if (mounted) {
        if (state.type == WebViewState.finishLoad && !state.url.contains('google')) {
          debugPrint('loaded...');
          await _onPageLoaded();
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
            final userAgent = FlutterUserAgent.webViewUserAgent.replaceAll(RegExp(r'wv'), '');
            if (state.hasInternetConnection) {
              return WebviewScaffold(
                url: state.mapUrl,
                userAgent: userAgent,
                ignoreSSLErrors: true,
                withJavascript: true,
                withLocalStorage: true,
                appCacheEnabled: true,
                clearCookies: false,
                clearCache: false,
                initialChild: const Center(
                  child: CircularProgressIndicator(),
                ),
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

  Future<void> _onPageLoaded() async {
    await flutterWebviewPlugin.resize(_buildRect());
    await flutterWebviewPlugin.evalJavascript(script);
  }
}
