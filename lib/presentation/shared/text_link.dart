import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextLink extends StatelessWidget {
  final String text;
  final String url;
  final Function? onTap;

  const TextLink({
    super.key,
    required this.text,
    required this.url,
    this.onTap,
  });

  const TextLink.withoutLink({
    super.key,
    required this.text,
    required this.onTap,
  }) : url = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                fontSize: 18,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => onTap != null ? onTap!() : _launchUrl(url),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
