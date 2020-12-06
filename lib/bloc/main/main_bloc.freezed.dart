// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'main_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$MainEventTearOff {
  const _$MainEventTearOff();

// ignore: unused_element
  MainInitEvent init() {
    return const MainInitEvent();
  }

// ignore: unused_element
  MainThemeChangedEvent themeChanged({@required AppThemeType theme}) {
    return MainThemeChangedEvent(
      theme: theme,
    );
  }

// ignore: unused_element
  MainAccentColorChangedEvent accentColorChanged(
      {@required AppAccentColorType accentColor}) {
    return MainAccentColorChangedEvent(
      accentColor: accentColor,
    );
  }

// ignore: unused_element
  MainGoToTabEvent goToTab({@required int index}) {
    return MainGoToTabEvent(
      index: index,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $MainEvent = _$MainEventTearOff();

/// @nodoc
mixin _$MainEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType theme),
    @required TResult accentColorChanged(AppAccentColorType accentColor),
    @required TResult goToTab(int index),
  });
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType theme),
    TResult accentColorChanged(AppAccentColorType accentColor),
    TResult goToTab(int index),
    @required TResult orElse(),
  });
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(MainInitEvent value),
    @required TResult themeChanged(MainThemeChangedEvent value),
    @required TResult accentColorChanged(MainAccentColorChangedEvent value),
    @required TResult goToTab(MainGoToTabEvent value),
  });
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(MainInitEvent value),
    TResult themeChanged(MainThemeChangedEvent value),
    TResult accentColorChanged(MainAccentColorChangedEvent value),
    TResult goToTab(MainGoToTabEvent value),
    @required TResult orElse(),
  });
}

/// @nodoc
abstract class $MainEventCopyWith<$Res> {
  factory $MainEventCopyWith(MainEvent value, $Res Function(MainEvent) then) =
      _$MainEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$MainEventCopyWithImpl<$Res> implements $MainEventCopyWith<$Res> {
  _$MainEventCopyWithImpl(this._value, this._then);

  final MainEvent _value;
  // ignore: unused_field
  final $Res Function(MainEvent) _then;
}

/// @nodoc
abstract class $MainInitEventCopyWith<$Res> {
  factory $MainInitEventCopyWith(
          MainInitEvent value, $Res Function(MainInitEvent) then) =
      _$MainInitEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$MainInitEventCopyWithImpl<$Res> extends _$MainEventCopyWithImpl<$Res>
    implements $MainInitEventCopyWith<$Res> {
  _$MainInitEventCopyWithImpl(
      MainInitEvent _value, $Res Function(MainInitEvent) _then)
      : super(_value, (v) => _then(v as MainInitEvent));

  @override
  MainInitEvent get _value => super._value as MainInitEvent;
}

/// @nodoc
class _$MainInitEvent extends MainInitEvent {
  const _$MainInitEvent() : super._();

  @override
  String toString() {
    return 'MainEvent.init()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is MainInitEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType theme),
    @required TResult accentColorChanged(AppAccentColorType accentColor),
    @required TResult goToTab(int index),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return init();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType theme),
    TResult accentColorChanged(AppAccentColorType accentColor),
    TResult goToTab(int index),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (init != null) {
      return init();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(MainInitEvent value),
    @required TResult themeChanged(MainThemeChangedEvent value),
    @required TResult accentColorChanged(MainAccentColorChangedEvent value),
    @required TResult goToTab(MainGoToTabEvent value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return init(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(MainInitEvent value),
    TResult themeChanged(MainThemeChangedEvent value),
    TResult accentColorChanged(MainAccentColorChangedEvent value),
    TResult goToTab(MainGoToTabEvent value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (init != null) {
      return init(this);
    }
    return orElse();
  }
}

abstract class MainInitEvent extends MainEvent {
  const MainInitEvent._() : super._();
  const factory MainInitEvent() = _$MainInitEvent;
}

/// @nodoc
abstract class $MainThemeChangedEventCopyWith<$Res> {
  factory $MainThemeChangedEventCopyWith(MainThemeChangedEvent value,
          $Res Function(MainThemeChangedEvent) then) =
      _$MainThemeChangedEventCopyWithImpl<$Res>;
  $Res call({AppThemeType theme});
}

/// @nodoc
class _$MainThemeChangedEventCopyWithImpl<$Res>
    extends _$MainEventCopyWithImpl<$Res>
    implements $MainThemeChangedEventCopyWith<$Res> {
  _$MainThemeChangedEventCopyWithImpl(
      MainThemeChangedEvent _value, $Res Function(MainThemeChangedEvent) _then)
      : super(_value, (v) => _then(v as MainThemeChangedEvent));

  @override
  MainThemeChangedEvent get _value => super._value as MainThemeChangedEvent;

  @override
  $Res call({
    Object theme = freezed,
  }) {
    return _then(MainThemeChangedEvent(
      theme: theme == freezed ? _value.theme : theme as AppThemeType,
    ));
  }
}

/// @nodoc
class _$MainThemeChangedEvent extends MainThemeChangedEvent {
  const _$MainThemeChangedEvent({@required this.theme})
      : assert(theme != null),
        super._();

  @override
  final AppThemeType theme;

  @override
  String toString() {
    return 'MainEvent.themeChanged(theme: $theme)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is MainThemeChangedEvent &&
            (identical(other.theme, theme) ||
                const DeepCollectionEquality().equals(other.theme, theme)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(theme);

  @override
  $MainThemeChangedEventCopyWith<MainThemeChangedEvent> get copyWith =>
      _$MainThemeChangedEventCopyWithImpl<MainThemeChangedEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType theme),
    @required TResult accentColorChanged(AppAccentColorType accentColor),
    @required TResult goToTab(int index),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return themeChanged(theme);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType theme),
    TResult accentColorChanged(AppAccentColorType accentColor),
    TResult goToTab(int index),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (themeChanged != null) {
      return themeChanged(theme);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(MainInitEvent value),
    @required TResult themeChanged(MainThemeChangedEvent value),
    @required TResult accentColorChanged(MainAccentColorChangedEvent value),
    @required TResult goToTab(MainGoToTabEvent value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return themeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(MainInitEvent value),
    TResult themeChanged(MainThemeChangedEvent value),
    TResult accentColorChanged(MainAccentColorChangedEvent value),
    TResult goToTab(MainGoToTabEvent value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (themeChanged != null) {
      return themeChanged(this);
    }
    return orElse();
  }
}

abstract class MainThemeChangedEvent extends MainEvent {
  const MainThemeChangedEvent._() : super._();
  const factory MainThemeChangedEvent({@required AppThemeType theme}) =
      _$MainThemeChangedEvent;

  AppThemeType get theme;
  $MainThemeChangedEventCopyWith<MainThemeChangedEvent> get copyWith;
}

/// @nodoc
abstract class $MainAccentColorChangedEventCopyWith<$Res> {
  factory $MainAccentColorChangedEventCopyWith(
          MainAccentColorChangedEvent value,
          $Res Function(MainAccentColorChangedEvent) then) =
      _$MainAccentColorChangedEventCopyWithImpl<$Res>;
  $Res call({AppAccentColorType accentColor});
}

/// @nodoc
class _$MainAccentColorChangedEventCopyWithImpl<$Res>
    extends _$MainEventCopyWithImpl<$Res>
    implements $MainAccentColorChangedEventCopyWith<$Res> {
  _$MainAccentColorChangedEventCopyWithImpl(MainAccentColorChangedEvent _value,
      $Res Function(MainAccentColorChangedEvent) _then)
      : super(_value, (v) => _then(v as MainAccentColorChangedEvent));

  @override
  MainAccentColorChangedEvent get _value =>
      super._value as MainAccentColorChangedEvent;

  @override
  $Res call({
    Object accentColor = freezed,
  }) {
    return _then(MainAccentColorChangedEvent(
      accentColor: accentColor == freezed
          ? _value.accentColor
          : accentColor as AppAccentColorType,
    ));
  }
}

/// @nodoc
class _$MainAccentColorChangedEvent extends MainAccentColorChangedEvent {
  const _$MainAccentColorChangedEvent({@required this.accentColor})
      : assert(accentColor != null),
        super._();

  @override
  final AppAccentColorType accentColor;

  @override
  String toString() {
    return 'MainEvent.accentColorChanged(accentColor: $accentColor)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is MainAccentColorChangedEvent &&
            (identical(other.accentColor, accentColor) ||
                const DeepCollectionEquality()
                    .equals(other.accentColor, accentColor)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(accentColor);

  @override
  $MainAccentColorChangedEventCopyWith<MainAccentColorChangedEvent>
      get copyWith => _$MainAccentColorChangedEventCopyWithImpl<
          MainAccentColorChangedEvent>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType theme),
    @required TResult accentColorChanged(AppAccentColorType accentColor),
    @required TResult goToTab(int index),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return accentColorChanged(accentColor);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType theme),
    TResult accentColorChanged(AppAccentColorType accentColor),
    TResult goToTab(int index),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (accentColorChanged != null) {
      return accentColorChanged(accentColor);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(MainInitEvent value),
    @required TResult themeChanged(MainThemeChangedEvent value),
    @required TResult accentColorChanged(MainAccentColorChangedEvent value),
    @required TResult goToTab(MainGoToTabEvent value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return accentColorChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(MainInitEvent value),
    TResult themeChanged(MainThemeChangedEvent value),
    TResult accentColorChanged(MainAccentColorChangedEvent value),
    TResult goToTab(MainGoToTabEvent value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (accentColorChanged != null) {
      return accentColorChanged(this);
    }
    return orElse();
  }
}

abstract class MainAccentColorChangedEvent extends MainEvent {
  const MainAccentColorChangedEvent._() : super._();
  const factory MainAccentColorChangedEvent(
          {@required AppAccentColorType accentColor}) =
      _$MainAccentColorChangedEvent;

  AppAccentColorType get accentColor;
  $MainAccentColorChangedEventCopyWith<MainAccentColorChangedEvent>
      get copyWith;
}

/// @nodoc
abstract class $MainGoToTabEventCopyWith<$Res> {
  factory $MainGoToTabEventCopyWith(
          MainGoToTabEvent value, $Res Function(MainGoToTabEvent) then) =
      _$MainGoToTabEventCopyWithImpl<$Res>;
  $Res call({int index});
}

/// @nodoc
class _$MainGoToTabEventCopyWithImpl<$Res> extends _$MainEventCopyWithImpl<$Res>
    implements $MainGoToTabEventCopyWith<$Res> {
  _$MainGoToTabEventCopyWithImpl(
      MainGoToTabEvent _value, $Res Function(MainGoToTabEvent) _then)
      : super(_value, (v) => _then(v as MainGoToTabEvent));

  @override
  MainGoToTabEvent get _value => super._value as MainGoToTabEvent;

  @override
  $Res call({
    Object index = freezed,
  }) {
    return _then(MainGoToTabEvent(
      index: index == freezed ? _value.index : index as int,
    ));
  }
}

/// @nodoc
class _$MainGoToTabEvent extends MainGoToTabEvent {
  const _$MainGoToTabEvent({@required this.index})
      : assert(index != null),
        super._();

  @override
  final int index;

  @override
  String toString() {
    return 'MainEvent.goToTab(index: $index)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is MainGoToTabEvent &&
            (identical(other.index, index) ||
                const DeepCollectionEquality().equals(other.index, index)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(index);

  @override
  $MainGoToTabEventCopyWith<MainGoToTabEvent> get copyWith =>
      _$MainGoToTabEventCopyWithImpl<MainGoToTabEvent>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType theme),
    @required TResult accentColorChanged(AppAccentColorType accentColor),
    @required TResult goToTab(int index),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return goToTab(index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType theme),
    TResult accentColorChanged(AppAccentColorType accentColor),
    TResult goToTab(int index),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (goToTab != null) {
      return goToTab(index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(MainInitEvent value),
    @required TResult themeChanged(MainThemeChangedEvent value),
    @required TResult accentColorChanged(MainAccentColorChangedEvent value),
    @required TResult goToTab(MainGoToTabEvent value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    return goToTab(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(MainInitEvent value),
    TResult themeChanged(MainThemeChangedEvent value),
    TResult accentColorChanged(MainAccentColorChangedEvent value),
    TResult goToTab(MainGoToTabEvent value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (goToTab != null) {
      return goToTab(this);
    }
    return orElse();
  }
}

abstract class MainGoToTabEvent extends MainEvent {
  const MainGoToTabEvent._() : super._();
  const factory MainGoToTabEvent({@required int index}) = _$MainGoToTabEvent;

  int get index;
  $MainGoToTabEventCopyWith<MainGoToTabEvent> get copyWith;
}

/// @nodoc
class _$MainStateTearOff {
  const _$MainStateTearOff();

// ignore: unused_element
  _MainLoadingState loading() {
    return const _MainLoadingState();
  }

// ignore: unused_element
  _MainLoadedState loaded(
      {@required String appTitle,
      @required ThemeData theme,
      @required bool initialized,
      @required bool firstInstall,
      int currentSelectedTab = 0}) {
    return _MainLoadedState(
      appTitle: appTitle,
      theme: theme,
      initialized: initialized,
      firstInstall: firstInstall,
      currentSelectedTab: currentSelectedTab,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $MainState = _$MainStateTearOff();

/// @nodoc
mixin _$MainState {
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult loading(),
    @required
        TResult loaded(String appTitle, ThemeData theme, bool initialized,
            bool firstInstall, int currentSelectedTab),
  });
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult loading(),
    TResult loaded(String appTitle, ThemeData theme, bool initialized,
        bool firstInstall, int currentSelectedTab),
    @required TResult orElse(),
  });
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult loading(_MainLoadingState value),
    @required TResult loaded(_MainLoadedState value),
  });
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult loading(_MainLoadingState value),
    TResult loaded(_MainLoadedState value),
    @required TResult orElse(),
  });
}

/// @nodoc
abstract class $MainStateCopyWith<$Res> {
  factory $MainStateCopyWith(MainState value, $Res Function(MainState) then) =
      _$MainStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$MainStateCopyWithImpl<$Res> implements $MainStateCopyWith<$Res> {
  _$MainStateCopyWithImpl(this._value, this._then);

  final MainState _value;
  // ignore: unused_field
  final $Res Function(MainState) _then;
}

/// @nodoc
abstract class _$MainLoadingStateCopyWith<$Res> {
  factory _$MainLoadingStateCopyWith(
          _MainLoadingState value, $Res Function(_MainLoadingState) then) =
      __$MainLoadingStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$MainLoadingStateCopyWithImpl<$Res>
    extends _$MainStateCopyWithImpl<$Res>
    implements _$MainLoadingStateCopyWith<$Res> {
  __$MainLoadingStateCopyWithImpl(
      _MainLoadingState _value, $Res Function(_MainLoadingState) _then)
      : super(_value, (v) => _then(v as _MainLoadingState));

  @override
  _MainLoadingState get _value => super._value as _MainLoadingState;
}

/// @nodoc
class _$_MainLoadingState extends _MainLoadingState {
  const _$_MainLoadingState() : super._();

  @override
  String toString() {
    return 'MainState.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _MainLoadingState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult loading(),
    @required
        TResult loaded(String appTitle, ThemeData theme, bool initialized,
            bool firstInstall, int currentSelectedTab),
  }) {
    assert(loading != null);
    assert(loaded != null);
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult loading(),
    TResult loaded(String appTitle, ThemeData theme, bool initialized,
        bool firstInstall, int currentSelectedTab),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult loading(_MainLoadingState value),
    @required TResult loaded(_MainLoadedState value),
  }) {
    assert(loading != null);
    assert(loaded != null);
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult loading(_MainLoadingState value),
    TResult loaded(_MainLoadedState value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _MainLoadingState extends MainState {
  const _MainLoadingState._() : super._();
  const factory _MainLoadingState() = _$_MainLoadingState;
}

/// @nodoc
abstract class _$MainLoadedStateCopyWith<$Res> {
  factory _$MainLoadedStateCopyWith(
          _MainLoadedState value, $Res Function(_MainLoadedState) then) =
      __$MainLoadedStateCopyWithImpl<$Res>;
  $Res call(
      {String appTitle,
      ThemeData theme,
      bool initialized,
      bool firstInstall,
      int currentSelectedTab});
}

/// @nodoc
class __$MainLoadedStateCopyWithImpl<$Res> extends _$MainStateCopyWithImpl<$Res>
    implements _$MainLoadedStateCopyWith<$Res> {
  __$MainLoadedStateCopyWithImpl(
      _MainLoadedState _value, $Res Function(_MainLoadedState) _then)
      : super(_value, (v) => _then(v as _MainLoadedState));

  @override
  _MainLoadedState get _value => super._value as _MainLoadedState;

  @override
  $Res call({
    Object appTitle = freezed,
    Object theme = freezed,
    Object initialized = freezed,
    Object firstInstall = freezed,
    Object currentSelectedTab = freezed,
  }) {
    return _then(_MainLoadedState(
      appTitle: appTitle == freezed ? _value.appTitle : appTitle as String,
      theme: theme == freezed ? _value.theme : theme as ThemeData,
      initialized:
          initialized == freezed ? _value.initialized : initialized as bool,
      firstInstall:
          firstInstall == freezed ? _value.firstInstall : firstInstall as bool,
      currentSelectedTab: currentSelectedTab == freezed
          ? _value.currentSelectedTab
          : currentSelectedTab as int,
    ));
  }
}

/// @nodoc
class _$_MainLoadedState extends _MainLoadedState {
  const _$_MainLoadedState(
      {@required this.appTitle,
      @required this.theme,
      @required this.initialized,
      @required this.firstInstall,
      this.currentSelectedTab = 0})
      : assert(appTitle != null),
        assert(theme != null),
        assert(initialized != null),
        assert(firstInstall != null),
        assert(currentSelectedTab != null),
        super._();

  @override
  final String appTitle;
  @override
  final ThemeData theme;
  @override
  final bool initialized;
  @override
  final bool firstInstall;
  @JsonKey(defaultValue: 0)
  @override
  final int currentSelectedTab;

  @override
  String toString() {
    return 'MainState.loaded(appTitle: $appTitle, theme: $theme, initialized: $initialized, firstInstall: $firstInstall, currentSelectedTab: $currentSelectedTab)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _MainLoadedState &&
            (identical(other.appTitle, appTitle) ||
                const DeepCollectionEquality()
                    .equals(other.appTitle, appTitle)) &&
            (identical(other.theme, theme) ||
                const DeepCollectionEquality().equals(other.theme, theme)) &&
            (identical(other.initialized, initialized) ||
                const DeepCollectionEquality()
                    .equals(other.initialized, initialized)) &&
            (identical(other.firstInstall, firstInstall) ||
                const DeepCollectionEquality()
                    .equals(other.firstInstall, firstInstall)) &&
            (identical(other.currentSelectedTab, currentSelectedTab) ||
                const DeepCollectionEquality()
                    .equals(other.currentSelectedTab, currentSelectedTab)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(appTitle) ^
      const DeepCollectionEquality().hash(theme) ^
      const DeepCollectionEquality().hash(initialized) ^
      const DeepCollectionEquality().hash(firstInstall) ^
      const DeepCollectionEquality().hash(currentSelectedTab);

  @override
  _$MainLoadedStateCopyWith<_MainLoadedState> get copyWith =>
      __$MainLoadedStateCopyWithImpl<_MainLoadedState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult loading(),
    @required
        TResult loaded(String appTitle, ThemeData theme, bool initialized,
            bool firstInstall, int currentSelectedTab),
  }) {
    assert(loading != null);
    assert(loaded != null);
    return loaded(
        appTitle, theme, initialized, firstInstall, currentSelectedTab);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult loading(),
    TResult loaded(String appTitle, ThemeData theme, bool initialized,
        bool firstInstall, int currentSelectedTab),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (loaded != null) {
      return loaded(
          appTitle, theme, initialized, firstInstall, currentSelectedTab);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult loading(_MainLoadingState value),
    @required TResult loaded(_MainLoadedState value),
  }) {
    assert(loading != null);
    assert(loaded != null);
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult loading(_MainLoadingState value),
    TResult loaded(_MainLoadedState value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _MainLoadedState extends MainState {
  const _MainLoadedState._() : super._();
  const factory _MainLoadedState(
      {@required String appTitle,
      @required ThemeData theme,
      @required bool initialized,
      @required bool firstInstall,
      int currentSelectedTab}) = _$_MainLoadedState;

  String get appTitle;
  ThemeData get theme;
  bool get initialized;
  bool get firstInstall;
  int get currentSelectedTab;
  _$MainLoadedStateCopyWith<_MainLoadedState> get copyWith;
}
