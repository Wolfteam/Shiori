import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/page_message.dart';

class WishSimulatorPage extends StatefulWidget {
  @override
  _WishSimulatorPageState createState() => _WishSimulatorPageState();
}

class _WishSimulatorPageState extends State<WishSimulatorPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  final script = '''
    function closeModal(){
      if (!document.getElementsByClassName("modal-container"))
        return;
      let modal = document.getElementsByClassName("modal-container")[0];
      if (!modal)
        return;
      let closeModalBtn = modal.querySelector(".close-button");
      if (!closeModalBtn)
        return;
      
      closeModalBtn.click();
    }
    
    setTimeout(closeModal, 300);
    setTimeout(closeModal, 1200);
    setTimeout(closeModal, 3000);
    setTimeout(closeModal, 6000);
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
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: false, loadWishSimulator: true, loadDailyCheckIn: false));
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebviewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(child: BlocBuilder<UrlPageBloc, UrlPageState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) {
            if (state.hasInternetConnection) {
              return WebviewScaffold(
                appBar: AppBar(title: Text(s.wishSimulator)),
                url: state.wishSimulatorUrl,
                hidden: true,
                clearCache: true,
                clearCookies: true,
              );
            }
            return PageMessage(text: s.noInternetConnection);
          },
        );
      },
    ));
  }

  void _onPageLoaded() {
    flutterWebviewPlugin.evalJavascript(script);
  }
}
