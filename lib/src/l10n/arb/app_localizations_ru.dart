// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get wordContinue => 'Продолжить';

  @override
  String get noConfigImportedText =>
      'Для подключения к свободному интернету\nвам нужна ссылка на конфигурацию или JSON-конфигурация.';

  @override
  String get wordImport => 'Импортировать';

  @override
  String get wordSubmit => 'Применить';

  @override
  String get neverMind => 'Не важно';

  @override
  String get checkInternetConnection =>
      'Проверьте состояние вашего интернет-соединения!';

  @override
  String get slideToDisconnect => 'Проведите для отключения';

  @override
  String get activeTimeText => 'АКТИВНОЕ ВРЕМЯ';

  @override
  String get addYourConfig => 'Добавьте свою конфигурацию';

  @override
  String get hasActiveSub_MainScreen =>
      'Для улучшения условий подключения\nвы всегда можете импортировать другую конфигурацию.';

  @override
  String get anErrorHappened => 'Произошла ошибка';
}
