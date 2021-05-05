import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/page_message.dart';

class DailyCheckInPage extends StatefulWidget {
  @override
  _DailyCheckInPageState createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  final script = '''
    function removeButtons() {
      const backButton = document.querySelectorAll('div[class*="back"]');
      const shareButton = document.querySelectorAll('div[class*="share"]');
  
      if (backButton && shareButton) {
          backButton[0].remove();
          shareButton[0].remove();
      }
    }

    setTimeout(removeButtons, 300);
    setTimeout(removeButtons, 1200);
    setTimeout(removeButtons, 3000);
    setTimeout(removeButtons, 6000);
   ''';

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
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
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: false, loadWishSimulator: false, loadDailyCheckIn: true));
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebViewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: BlocBuilder<UrlPageBloc, UrlPageState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(),
            loaded: (state) {
              if (state.hasInternetConnection) {
                return WebviewScaffold(
                  appBar: AppBar(title: Text(s.dailyCheckIn)),
                  url: state.dailyCheckInUrl,
                  hidden: true,
                );
              }
              return PageMessage(text: s.noInternetConnection);
            },
          );
        },
      ),
    );
  }

  void _onPageLoaded() {
    flutterWebViewPlugin.evalJavascript(script);
  }
}
