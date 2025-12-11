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

  @override
  String get customization => 'Customization';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get connectionMode => 'Connection Mode';

  @override
  String get connectionModeProxy => 'Proxy';

  @override
  String get connectionModeVpn => 'VPN';

  @override
  String get coreType => 'Core Type';

  @override
  String get confirm => 'Confirm';

  @override
  String get restoreDefaults => 'Restore to default';

  @override
  String get settings => 'Settings';

  @override
  String get logs => 'Logs';

  @override
  String get about => 'About';

  @override
  String get mainSettings => 'Main Settings';

  @override
  String get connectionSuccess => 'Connected successfully';

  @override
  String get profileSavedSuccess => 'Profile saved successfully';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get addingProfile => 'Adding profile';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get deleteProfile => 'Delete';

  @override
  String get deleteProfileConfirm => 'Delete profile?';

  @override
  String deleteProfileMessage(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get newProfile => 'New Profile';

  @override
  String get updateSubscriptions => 'Update Subscriptions';

  @override
  String get updating => 'Updating...';

  @override
  String get update => 'Update';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get exportSubLink => 'Export subscription link to clipboard';

  @override
  String get qrCodeSubLink => 'QR Code subscription link';

  @override
  String get addConfigToClipboard => 'Add config to clipboard';

  @override
  String get addNewProfile => 'Add new profile';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deleteAllConfirm => 'Are you sure you want to delete all configs?';

  @override
  String get sort => 'Sort';

  @override
  String daysRemaining(String days) {
    return '$days days remaining';
  }

  @override
  String get unlimitedDays => '∞ days remaining';

  @override
  String get expired => 'Expired';

  @override
  String get startWithProfile => 'Start by adding a subscription profile';

  @override
  String get localConfigs => 'Local Configs';
}
