import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watashi/src/l10n/arb/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Supported locales in the app
class SupportedLocales {
  static const en = Locale('en');
  static const fa = Locale('fa');
  static const ru = Locale('ru');

  static const all = [en, fa, ru];

  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fa':
        return 'فارسی';
      case 'ru':
        return 'Русский';
      default:
        return locale.languageCode;
    }
  }
}

/// provider used to access the AppLocalizations object for the current locale
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  // 1. initialize from the initial locale
  ref.state = lookupAppLocalizations(PlatformDispatcher.instance.locale);

  final appLocale = ref.watch(localeProvider);
  if (appLocale != null) {
    ref.state = lookupAppLocalizations(appLocale);
  }
  final observer = _LocaleObserver((locales) {
    // priority is given to the locale set by user within the app over system
    // wide locale
    ref.state =
        lookupAppLocalizations(appLocale ?? PlatformDispatcher.instance.locale);
  });
  // 3. register the observer and dispose it when no longer needed
  final binding = WidgetsBinding.instance..addObserver(observer);
  ref.onDispose(() => binding.removeObserver(observer));
  // 4. return the state
  return ref.state;
});

/// observer used to notify the caller when the locale changes
class _LocaleObserver extends WidgetsBindingObserver {
  _LocaleObserver(this._didChangeLocales);

  final void Function(List<Locale>? locales) _didChangeLocales;

  @override
  void didChangeLocales(List<Locale>? locales) {
    _didChangeLocales(locales);
  }
}

/// Locale provider with persistence
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(SupportedLocales.en) {
    _loadLocale();
  }

  static const _key = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_key);
    if (languageCode != null) {
      state = Locale(languageCode);
    } else {
      // Default to English if no locale is saved
      state = SupportedLocales.en;
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString(_key, locale.languageCode);
    } else {
      await prefs.remove(_key);
    }
  }
}
