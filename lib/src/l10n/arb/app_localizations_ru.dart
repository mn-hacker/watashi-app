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

  @override
  String get scanQRCode => 'Сканировать QR-код';

  @override
  String get addFromClipboard => 'Добавить из буфера';

  @override
  String get manualAdd => 'Добавить вручную';

  @override
  String get configAddedSuccess => 'Конфигурация успешно добавлена';

  @override
  String get invalidQRCode => 'Неверный QR-код';

  @override
  String get clipboardEmpty => 'Буфер обмена пуст';

  @override
  String get noConfigInClipboard => 'В буфере обмена нет конфигурации';

  @override
  String get addConfig => 'Добавить конфигурацию';

  @override
  String get home => 'Главная';

  @override
  String get proxies => 'Прокси';

  @override
  String get autoSelect => 'авто';

  @override
  String get serviceNotRunning => 'Служба не запущена';

  @override
  String get connectToViewProxies => 'Подключитесь для просмотра прокси';

  @override
  String get sortByPing => 'Сортировать по пингу';

  @override
  String get refreshPing => 'Обновить пинг';

  @override
  String get editConfig => 'Редактировать';

  @override
  String get deleteConfig => 'Удалить';

  @override
  String get configRemark => 'Название';

  @override
  String get configAddress => 'Адрес';

  @override
  String get configPort => 'Порт';

  @override
  String get configUuid => 'UUID';

  @override
  String get saveChanges => 'Сохранить';

  @override
  String get customization => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get connectionMode => 'Режим подключения';

  @override
  String get connectionModeProxy => 'Прокси';

  @override
  String get connectionModeVpn => 'VPN';

  @override
  String get coreType => 'Тип ядра';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get restoreDefaults => 'Сбросить настройки';

  @override
  String get settings => 'Настройки';

  @override
  String get logs => 'Логи';

  @override
  String get about => 'О программе';

  @override
  String get mainSettings => 'Основные настройки';
}
