import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../../bloc/bloc.dart';
import '../../generated/l10n.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/page_message.dart';

class WishSimulatorPage extends StatefulWidget {
  @override
  _WishSimulatorPageState createState() => _WishSimulatorPageState();
}

class _WishSimulatorPageState extends State<WishSimulatorPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: false, loadWishSimulator: true));
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebviewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.wishSimulator)),
      body: SafeArea(
        child: BlocBuilder<UrlPageBloc, UrlPageState>(
          builder: (context, state) {
            return state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) {
                if (state.hasInternetConnection) {
                  return WebviewScaffold(
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
        ),
      ),
    );
  }
}
