// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get wordContinue => 'ادامه';

  @override
  String get noConfigImportedText =>
      'برای اتصال به اینترنت آزاد،\nشما به یک لینک کانفیگ یا کانفیگ JSON نیاز دارید.';

  @override
  String get wordImport => 'وارد کردن';

  @override
  String get wordSubmit => 'ثبت';

  @override
  String get neverMind => 'بیخیال';

  @override
  String get checkInternetConnection =>
      'وضعیت اتصال اینترنت خود را بررسی کنید!';

  @override
  String get slideToDisconnect => 'برای قطع اتصال بکشید';

  @override
  String get activeTimeText => 'زمان فعال';

  @override
  String get addYourConfig => 'کانفیگ خود را اضافه کنید';

  @override
  String get hasActiveSub_MainScreen =>
      'برای بهبود شرایط اتصال،\nمی‌توانید همیشه کانفیگ دیگری وارد کنید.';

  @override
  String get anErrorHappened => 'خطایی رخ داد';
}
