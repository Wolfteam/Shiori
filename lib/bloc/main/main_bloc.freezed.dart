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
  _Init init() {
    return const _Init();
  }

// ignore: unused_element
  _ThemeChanged themeChanged({@required AppThemeType newValue}) {
    return _ThemeChanged(
      newValue: newValue,
    );
  }

// ignore: unused_element
  _AccentColorChanged accentColorChanged(
      {@required AppAccentColorType newValue}) {
    return _AccentColorChanged(
      newValue: newValue,
    );
  }

// ignore: unused_element
  _GoToTab goToTab({@required int index}) {
    return _GoToTab(
      index: index,
    );
  }

// ignore: unused_element
  _LanguageChanged languageChanged({@required AppLanguageType newValue}) {
    return _LanguageChanged(
      newValue: newValue,
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
    @required TResult themeChanged(AppThemeType newValue),
    @required TResult accentColorChanged(AppAccentColorType newValue),
    @required TResult goToTab(int index),
    @required TResult languageChanged(AppLanguageType newValue),
  });
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType newValue),
    TResult accentColorChanged(AppAccentColorType newValue),
    TResult goToTab(int index),
    TResult languageChanged(AppLanguageType newValue),
    @required TResult orElse(),
  });
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(_Init value),
    @required TResult themeChanged(_ThemeChanged value),
    @required TResult accentColorChanged(_AccentColorChanged value),
    @required TResult goToTab(_GoToTab value),
    @required TResult languageChanged(_LanguageChanged value),
  });
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(_Init value),
    TResult themeChanged(_ThemeChanged value),
    TResult accentColorChanged(_AccentColorChanged value),
    TResult goToTab(_GoToTab value),
    TResult languageChanged(_LanguageChanged value),
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
abstract class _$InitCopyWith<$Res> {
  factory _$InitCopyWith(_Init value, $Res Function(_Init) then) =
      __$InitCopyWithImpl<$Res>;
}

/// @nodoc
class __$InitCopyWithImpl<$Res> extends _$MainEventCopyWithImpl<$Res>
    implements _$InitCopyWith<$Res> {
  __$InitCopyWithImpl(_Init _value, $Res Function(_Init) _then)
      : super(_value, (v) => _then(v as _Init));

  @override
  _Init get _value => super._value as _Init;
}

/// @nodoc
class _$_Init extends _Init {
  const _$_Init() : super._();

  @override
  String toString() {
    return 'MainEvent.init()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _Init);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType newValue),
    @required TResult accentColorChanged(AppAccentColorType newValue),
    @required TResult goToTab(int index),
    @required TResult languageChanged(AppLanguageType newValue),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return init();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType newValue),
    TResult accentColorChanged(AppAccentColorType newValue),
    TResult goToTab(int index),
    TResult languageChanged(AppLanguageType newValue),
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
    @required TResult init(_Init value),
    @required TResult themeChanged(_ThemeChanged value),
    @required TResult accentColorChanged(_AccentColorChanged value),
    @required TResult goToTab(_GoToTab value),
    @required TResult languageChanged(_LanguageChanged value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return init(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(_Init value),
    TResult themeChanged(_ThemeChanged value),
    TResult accentColorChanged(_AccentColorChanged value),
    TResult goToTab(_GoToTab value),
    TResult languageChanged(_LanguageChanged value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (init != null) {
      return init(this);
    }
    return orElse();
  }
}

abstract class _Init extends MainEvent {
  const _Init._() : super._();
  const factory _Init() = _$_Init;
}

/// @nodoc
abstract class _$ThemeChangedCopyWith<$Res> {
  factory _$ThemeChangedCopyWith(
          _ThemeChanged value, $Res Function(_ThemeChanged) then) =
      __$ThemeChangedCopyWithImpl<$Res>;
  $Res call({AppThemeType newValue});
}

/// @nodoc
class __$ThemeChangedCopyWithImpl<$Res> extends _$MainEventCopyWithImpl<$Res>
    implements _$ThemeChangedCopyWith<$Res> {
  __$ThemeChangedCopyWithImpl(
      _ThemeChanged _value, $Res Function(_ThemeChanged) _then)
      : super(_value, (v) => _then(v as _ThemeChanged));

  @override
  _ThemeChanged get _value => super._value as _ThemeChanged;

  @override
  $Res call({
    Object newValue = freezed,
  }) {
    return _then(_ThemeChanged(
      newValue:
          newValue == freezed ? _value.newValue : newValue as AppThemeType,
    ));
  }
}

/// @nodoc
class _$_ThemeChanged extends _ThemeChanged {
  const _$_ThemeChanged({@required this.newValue})
      : assert(newValue != null),
        super._();

  @override
  final AppThemeType newValue;

  @override
  String toString() {
    return 'MainEvent.themeChanged(newValue: $newValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ThemeChanged &&
            (identical(other.newValue, newValue) ||
                const DeepCollectionEquality()
                    .equals(other.newValue, newValue)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(newValue);

  @override
  _$ThemeChangedCopyWith<_ThemeChanged> get copyWith =>
      __$ThemeChangedCopyWithImpl<_ThemeChanged>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType newValue),
    @required TResult accentColorChanged(AppAccentColorType newValue),
    @required TResult goToTab(int index),
    @required TResult languageChanged(AppLanguageType newValue),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return themeChanged(newValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType newValue),
    TResult accentColorChanged(AppAccentColorType newValue),
    TResult goToTab(int index),
    TResult languageChanged(AppLanguageType newValue),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (themeChanged != null) {
      return themeChanged(newValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(_Init value),
    @required TResult themeChanged(_ThemeChanged value),
    @required TResult accentColorChanged(_AccentColorChanged value),
    @required TResult goToTab(_GoToTab value),
    @required TResult languageChanged(_LanguageChanged value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return themeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(_Init value),
    TResult themeChanged(_ThemeChanged value),
    TResult accentColorChanged(_AccentColorChanged value),
    TResult goToTab(_GoToTab value),
    TResult languageChanged(_LanguageChanged value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (themeChanged != null) {
      return themeChanged(this);
    }
    return orElse();
  }
}

abstract class _ThemeChanged extends MainEvent {
  const _ThemeChanged._() : super._();
  const factory _ThemeChanged({@required AppThemeType newValue}) =
      _$_ThemeChanged;

  AppThemeType get newValue;
  _$ThemeChangedCopyWith<_ThemeChanged> get copyWith;
}

/// @nodoc
abstract class _$AccentColorChangedCopyWith<$Res> {
  factory _$AccentColorChangedCopyWith(
          _AccentColorChanged value, $Res Function(_AccentColorChanged) then) =
      __$AccentColorChangedCopyWithImpl<$Res>;
  $Res call({AppAccentColorType newValue});
}

/// @nodoc
class __$AccentColorChangedCopyWithImpl<$Res>
    extends _$MainEventCopyWithImpl<$Res>
    implements _$AccentColorChangedCopyWith<$Res> {
  __$AccentColorChangedCopyWithImpl(
      _AccentColorChanged _value, $Res Function(_AccentColorChanged) _then)
      : super(_value, (v) => _then(v as _AccentColorChanged));

  @override
  _AccentColorChanged get _value => super._value as _AccentColorChanged;

  @override
  $Res call({
    Object newValue = freezed,
  }) {
    return _then(_AccentColorChanged(
      newValue: newValue == freezed
          ? _value.newValue
          : newValue as AppAccentColorType,
    ));
  }
}

/// @nodoc
class _$_AccentColorChanged extends _AccentColorChanged {
  const _$_AccentColorChanged({@required this.newValue})
      : assert(newValue != null),
        super._();

  @override
  final AppAccentColorType newValue;

  @override
  String toString() {
    return 'MainEvent.accentColorChanged(newValue: $newValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _AccentColorChanged &&
            (identical(other.newValue, newValue) ||
                const DeepCollectionEquality()
                    .equals(other.newValue, newValue)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(newValue);

  @override
  _$AccentColorChangedCopyWith<_AccentColorChanged> get copyWith =>
      __$AccentColorChangedCopyWithImpl<_AccentColorChanged>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType newValue),
    @required TResult accentColorChanged(AppAccentColorType newValue),
    @required TResult goToTab(int index),
    @required TResult languageChanged(AppLanguageType newValue),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return accentColorChanged(newValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType newValue),
    TResult accentColorChanged(AppAccentColorType newValue),
    TResult goToTab(int index),
    TResult languageChanged(AppLanguageType newValue),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (accentColorChanged != null) {
      return accentColorChanged(newValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(_Init value),
    @required TResult themeChanged(_ThemeChanged value),
    @required TResult accentColorChanged(_AccentColorChanged value),
    @required TResult goToTab(_GoToTab value),
    @required TResult languageChanged(_LanguageChanged value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return accentColorChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(_Init value),
    TResult themeChanged(_ThemeChanged value),
    TResult accentColorChanged(_AccentColorChanged value),
    TResult goToTab(_GoToTab value),
    TResult languageChanged(_LanguageChanged value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (accentColorChanged != null) {
      return accentColorChanged(this);
    }
    return orElse();
  }
}

abstract class _AccentColorChanged extends MainEvent {
  const _AccentColorChanged._() : super._();
  const factory _AccentColorChanged({@required AppAccentColorType newValue}) =
      _$_AccentColorChanged;

  AppAccentColorType get newValue;
  _$AccentColorChangedCopyWith<_AccentColorChanged> get copyWith;
}

/// @nodoc
abstract class _$GoToTabCopyWith<$Res> {
  factory _$GoToTabCopyWith(_GoToTab value, $Res Function(_GoToTab) then) =
      __$GoToTabCopyWithImpl<$Res>;
  $Res call({int index});
}

/// @nodoc
class __$GoToTabCopyWithImpl<$Res> extends _$MainEventCopyWithImpl<$Res>
    implements _$GoToTabCopyWith<$Res> {
  __$GoToTabCopyWithImpl(_GoToTab _value, $Res Function(_GoToTab) _then)
      : super(_value, (v) => _then(v as _GoToTab));

  @override
  _GoToTab get _value => super._value as _GoToTab;

  @override
  $Res call({
    Object index = freezed,
  }) {
    return _then(_GoToTab(
      index: index == freezed ? _value.index : index as int,
    ));
  }
}

/// @nodoc
class _$_GoToTab extends _GoToTab {
  const _$_GoToTab({@required this.index})
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
        (other is _GoToTab &&
            (identical(other.index, index) ||
                const DeepCollectionEquality().equals(other.index, index)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(index);

  @override
  _$GoToTabCopyWith<_GoToTab> get copyWith =>
      __$GoToTabCopyWithImpl<_GoToTab>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType newValue),
    @required TResult accentColorChanged(AppAccentColorType newValue),
    @required TResult goToTab(int index),
    @required TResult languageChanged(AppLanguageType newValue),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return goToTab(index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType newValue),
    TResult accentColorChanged(AppAccentColorType newValue),
    TResult goToTab(int index),
    TResult languageChanged(AppLanguageType newValue),
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
    @required TResult init(_Init value),
    @required TResult themeChanged(_ThemeChanged value),
    @required TResult accentColorChanged(_AccentColorChanged value),
    @required TResult goToTab(_GoToTab value),
    @required TResult languageChanged(_LanguageChanged value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return goToTab(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(_Init value),
    TResult themeChanged(_ThemeChanged value),
    TResult accentColorChanged(_AccentColorChanged value),
    TResult goToTab(_GoToTab value),
    TResult languageChanged(_LanguageChanged value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (goToTab != null) {
      return goToTab(this);
    }
    return orElse();
  }
}

abstract class _GoToTab extends MainEvent {
  const _GoToTab._() : super._();
  const factory _GoToTab({@required int index}) = _$_GoToTab;

  int get index;
  _$GoToTabCopyWith<_GoToTab> get copyWith;
}

/// @nodoc
abstract class _$LanguageChangedCopyWith<$Res> {
  factory _$LanguageChangedCopyWith(
          _LanguageChanged value, $Res Function(_LanguageChanged) then) =
      __$LanguageChangedCopyWithImpl<$Res>;
  $Res call({AppLanguageType newValue});
}

/// @nodoc
class __$LanguageChangedCopyWithImpl<$Res> extends _$MainEventCopyWithImpl<$Res>
    implements _$LanguageChangedCopyWith<$Res> {
  __$LanguageChangedCopyWithImpl(
      _LanguageChanged _value, $Res Function(_LanguageChanged) _then)
      : super(_value, (v) => _then(v as _LanguageChanged));

  @override
  _LanguageChanged get _value => super._value as _LanguageChanged;

  @override
  $Res call({
    Object newValue = freezed,
  }) {
    return _then(_LanguageChanged(
      newValue:
          newValue == freezed ? _value.newValue : newValue as AppLanguageType,
    ));
  }
}

/// @nodoc
class _$_LanguageChanged extends _LanguageChanged {
  const _$_LanguageChanged({@required this.newValue})
      : assert(newValue != null),
        super._();

  @override
  final AppLanguageType newValue;

  @override
  String toString() {
    return 'MainEvent.languageChanged(newValue: $newValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _LanguageChanged &&
            (identical(other.newValue, newValue) ||
                const DeepCollectionEquality()
                    .equals(other.newValue, newValue)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(newValue);

  @override
  _$LanguageChangedCopyWith<_LanguageChanged> get copyWith =>
      __$LanguageChangedCopyWithImpl<_LanguageChanged>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult init(),
    @required TResult themeChanged(AppThemeType newValue),
    @required TResult accentColorChanged(AppAccentColorType newValue),
    @required TResult goToTab(int index),
    @required TResult languageChanged(AppLanguageType newValue),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return languageChanged(newValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult init(),
    TResult themeChanged(AppThemeType newValue),
    TResult accentColorChanged(AppAccentColorType newValue),
    TResult goToTab(int index),
    TResult languageChanged(AppLanguageType newValue),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (languageChanged != null) {
      return languageChanged(newValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult init(_Init value),
    @required TResult themeChanged(_ThemeChanged value),
    @required TResult accentColorChanged(_AccentColorChanged value),
    @required TResult goToTab(_GoToTab value),
    @required TResult languageChanged(_LanguageChanged value),
  }) {
    assert(init != null);
    assert(themeChanged != null);
    assert(accentColorChanged != null);
    assert(goToTab != null);
    assert(languageChanged != null);
    return languageChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult init(_Init value),
    TResult themeChanged(_ThemeChanged value),
    TResult accentColorChanged(_AccentColorChanged value),
    TResult goToTab(_GoToTab value),
    TResult languageChanged(_LanguageChanged value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (languageChanged != null) {
      return languageChanged(this);
    }
    return orElse();
  }
}

abstract class _LanguageChanged extends MainEvent {
  const _LanguageChanged._() : super._();
  const factory _LanguageChanged({@required AppLanguageType newValue}) =
      _$_LanguageChanged;

  AppLanguageType get newValue;
  _$LanguageChangedCopyWith<_LanguageChanged> get copyWith;
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
      @required AppLanguageType currentLanguage,
      @required Locale currentLocale,
      int currentSelectedTab = 0}) {
    return _MainLoadedState(
      appTitle: appTitle,
      theme: theme,
      initialized: initialized,
      firstInstall: firstInstall,
      currentLanguage: currentLanguage,
      currentLocale: currentLocale,
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
        TResult loaded(
            String appTitle,
            ThemeData theme,
            bool initialized,
            bool firstInstall,
            AppLanguageType currentLanguage,
            Locale currentLocale,
            int currentSelectedTab),
  });
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult loading(),
    TResult loaded(
        String appTitle,
        ThemeData theme,
        bool initialized,
        bool firstInstall,
        AppLanguageType currentLanguage,
        Locale currentLocale,
        int currentSelectedTab),
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
        TResult loaded(
            String appTitle,
            ThemeData theme,
            bool initialized,
            bool firstInstall,
            AppLanguageType currentLanguage,
            Locale currentLocale,
            int currentSelectedTab),
  }) {
    assert(loading != null);
    assert(loaded != null);
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult loading(),
    TResult loaded(
        String appTitle,
        ThemeData theme,
        bool initialized,
        bool firstInstall,
        AppLanguageType currentLanguage,
        Locale currentLocale,
        int currentSelectedTab),
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
      AppLanguageType currentLanguage,
      Locale currentLocale,
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
    Object currentLanguage = freezed,
    Object currentLocale = freezed,
    Object currentSelectedTab = freezed,
  }) {
    return _then(_MainLoadedState(
      appTitle: appTitle == freezed ? _value.appTitle : appTitle as String,
      theme: theme == freezed ? _value.theme : theme as ThemeData,
      initialized:
          initialized == freezed ? _value.initialized : initialized as bool,
      firstInstall:
          firstInstall == freezed ? _value.firstInstall : firstInstall as bool,
      currentLanguage: currentLanguage == freezed
          ? _value.currentLanguage
          : currentLanguage as AppLanguageType,
      currentLocale: currentLocale == freezed
          ? _value.currentLocale
          : currentLocale as Locale,
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
      @required this.currentLanguage,
      @required this.currentLocale,
      this.currentSelectedTab = 0})
      : assert(appTitle != null),
        assert(theme != null),
        assert(initialized != null),
        assert(firstInstall != null),
        assert(currentLanguage != null),
        assert(currentLocale != null),
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
  @override
  final AppLanguageType currentLanguage;
  @override
  final Locale currentLocale;
  @JsonKey(defaultValue: 0)
  @override
  final int currentSelectedTab;

  @override
  String toString() {
    return 'MainState.loaded(appTitle: $appTitle, theme: $theme, initialized: $initialized, firstInstall: $firstInstall, currentLanguage: $currentLanguage, currentLocale: $currentLocale, currentSelectedTab: $currentSelectedTab)';
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
            (identical(other.currentLanguage, currentLanguage) ||
                const DeepCollectionEquality()
                    .equals(other.currentLanguage, currentLanguage)) &&
            (identical(other.currentLocale, currentLocale) ||
                const DeepCollectionEquality()
                    .equals(other.currentLocale, currentLocale)) &&
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
      const DeepCollectionEquality().hash(currentLanguage) ^
      const DeepCollectionEquality().hash(currentLocale) ^
      const DeepCollectionEquality().hash(currentSelectedTab);

  @override
  _$MainLoadedStateCopyWith<_MainLoadedState> get copyWith =>
      __$MainLoadedStateCopyWithImpl<_MainLoadedState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult loading(),
    @required
        TResult loaded(
            String appTitle,
            ThemeData theme,
            bool initialized,
            bool firstInstall,
            AppLanguageType currentLanguage,
            Locale currentLocale,
            int currentSelectedTab),
  }) {
    assert(loading != null);
    assert(loaded != null);
    return loaded(appTitle, theme, initialized, firstInstall, currentLanguage,
        currentLocale, currentSelectedTab);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult loading(),
    TResult loaded(
        String appTitle,
        ThemeData theme,
        bool initialized,
        bool firstInstall,
        AppLanguageType currentLanguage,
        Locale currentLocale,
        int currentSelectedTab),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (loaded != null) {
      return loaded(appTitle, theme, initialized, firstInstall, currentLanguage,
          currentLocale, currentSelectedTab);
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
      @required AppLanguageType currentLanguage,
      @required Locale currentLocale,
      int currentSelectedTab}) = _$_MainLoadedState;

  String get appTitle;
  ThemeData get theme;
  bool get initialized;
  bool get firstInstall;
  AppLanguageType get currentLanguage;
  Locale get currentLocale;
  int get currentSelectedTab;
  _$MainLoadedStateCopyWith<_MainLoadedState> get copyWith;
}
