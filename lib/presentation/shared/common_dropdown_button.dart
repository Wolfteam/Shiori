import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class CommonDropdownButton<T> extends StatelessWidget {
  final String hint;
  final T? currentValue;
  final List<TranslatedEnum<T>> values;
  final Function(T, BuildContext)? onChanged;
  final bool isExpanded;
  final bool withoutUnderLine;
  final Widget Function(T)? leadingIconBuilder;
  final EdgeInsets? padding;
  final String? title;
  final String? subTitle;

  const CommonDropdownButton({
    super.key,
    required this.hint,
    this.currentValue,
    required this.values,
    this.onChanged,
    this.isExpanded = true,
    this.withoutUnderLine = true,
    this.leadingIconBuilder,
    this.padding = EdgeInsets.zero,
    this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      isExpanded: isExpanded,
      hint: Text(hint),
      value: currentValue,
      padding: padding,
      itemHeight: withoutUnderLine ? kMinInteractiveDimension : kMinInteractiveDimension + 10,
      underline: withoutUnderLine
          ? Container(
              height: 0,
              color: Colors.transparent,
            )
          : null,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      onChanged: onChanged != null ? (v) => onChanged!(v as T, context) : null,
      selectedItemBuilder: (context) => values.map((lang) => _Content(content: lang.translation, title: title, subTitle: subTitle)).toList(),
      items: values
          .map<DropdownMenuItem<T>>(
            (lang) => DropdownMenuItem<T>(
              value: lang.enumValue,
              child: _MenuItemContent(lang: lang, currentValue: currentValue, leadingIcon: leadingIconBuilder?.call(lang.enumValue)),
            ),
          )
          .toList(),
    );
  }
}

class _Content extends StatelessWidget {
  final String content;
  final String? title;
  final String? subTitle;

  const _Content({required this.content, this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainContent = Text(
      content,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
    if (title.isNullEmptyOrWhitespace && subTitle.isNullEmptyOrWhitespace) {
      return Align(
        alignment: Alignment.centerLeft,
        child: mainContent,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title.isNotNullEmptyOrWhitespace)
          Text(
            title!,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        mainContent,
        if (subTitle.isNotNullEmptyOrWhitespace)
          Text(
            subTitle!,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _MenuItemContent<T> extends StatelessWidget {
  final TranslatedEnum<T> lang;
  final T? currentValue;
  final Widget? leadingIcon;

  const _MenuItemContent({
    super.key,
    required this.lang,
    this.currentValue,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: lang.enumValue != currentValue ? const SizedBox(width: 20) : const Center(child: Icon(Icons.check, size: 20)),
        ),
        if (leadingIcon != null) leadingIcon!,
        Expanded(
          child: Text(
            lang.translation,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
