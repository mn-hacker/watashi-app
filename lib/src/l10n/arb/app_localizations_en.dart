// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get wordContinue => 'Continue';

  @override
  String get noConfigImportedText =>
      'To connect to unrestricted internet,\nyou need a config link or json config.';

  @override
  String get wordImport => 'Import';

  @override
  String get wordSubmit => 'Submit';

  @override
  String get neverMind => 'Never mind';

  @override
  String get checkInternetConnection =>
      'Check your internet connection status !';

  @override
  String get slideToDisconnect => 'Slide to disconnect';

  @override
  String get activeTimeText => 'ACTIVE TIME';

  @override
  String get addYourConfig => 'Add your config';

  @override
  String get hasActiveSub_MainScreen =>
      'To improve the connection conditions, \nyou can always import another config.';

  @override
  String get anErrorHappened => 'An error happened';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get addFromClipboard => 'Add from Clipboard';

  @override
  String get manualAdd => 'Manual Add';

  @override
  String get configAddedSuccess => 'Config added successfully';

  @override
  String get invalidQRCode => 'Invalid QR code';

  @override
  String get clipboardEmpty => 'Clipboard is empty';

  @override
  String get noConfigInClipboard => 'No valid config found in clipboard';

  @override
  String get addConfig => 'Add Config';

  @override
  String get home => 'Home';

  @override
  String get proxies => 'Proxies';

  @override
  String get autoSelect => 'auto';

  @override
  String get serviceNotRunning => 'Service is not running';

  @override
  String get connectToViewProxies => 'Connect to view proxies';

  @override
  String get sortByPing => 'Sort by ping';

  @override
  String get refreshPing => 'Refresh ping';

  @override
  String get editConfig => 'Edit Config';

  @override
  String get deleteConfig => 'Delete Config';

  @override
  String get configRemark => 'Remark';

  @override
  String get configAddress => 'Address';

  @override
  String get configPort => 'Port';

  @override
  String get configUuid => 'UUID';

  @override
  String get saveChanges => 'Save Changes';
}
