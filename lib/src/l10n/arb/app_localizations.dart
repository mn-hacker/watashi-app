import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('ru')
  ];

  /// No description provided for @wordContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wordContinue;

  /// No description provided for @noConfigImportedText.
  ///
  /// In en, this message translates to:
  /// **'To connect to unrestricted internet,\nyou need a config link or json config.'**
  String get noConfigImportedText;

  /// No description provided for @wordImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get wordImport;

  /// No description provided for @wordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get wordSubmit;

  /// No description provided for @neverMind.
  ///
  /// In en, this message translates to:
  /// **'Never mind'**
  String get neverMind;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection status !'**
  String get checkInternetConnection;

  /// No description provided for @slideToDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Slide to disconnect'**
  String get slideToDisconnect;

  /// No description provided for @activeTimeText.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TIME'**
  String get activeTimeText;

  /// No description provided for @addYourConfig.
  ///
  /// In en, this message translates to:
  /// **'Add your config'**
  String get addYourConfig;

  /// No description provided for @hasActiveSub_MainScreen.
  ///
  /// In en, this message translates to:
  /// **'To improve the connection conditions, \nyou can always import another config.'**
  String get hasActiveSub_MainScreen;

  /// No description provided for @anErrorHappened.
  ///
  /// In en, this message translates to:
  /// **'An error happened'**
  String get anErrorHappened;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @addFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Add from Clipboard'**
  String get addFromClipboard;

  /// No description provided for @manualAdd.
  ///
  /// In en, this message translates to:
  /// **'Manual Add'**
  String get manualAdd;

  /// No description provided for @configAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Config added successfully'**
  String get configAddedSuccess;

  /// No description provided for @invalidQRCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQRCode;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get clipboardEmpty;

  /// No description provided for @noConfigInClipboard.
  ///
  /// In en, this message translates to:
  /// **'No valid config found in clipboard'**
  String get noConfigInClipboard;

  /// No description provided for @addConfig.
  ///
  /// In en, this message translates to:
  /// **'Add Config'**
  String get addConfig;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @proxies.
  ///
  /// In en, this message translates to:
  /// **'Proxies'**
  String get proxies;

  /// No description provided for @autoSelect.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get autoSelect;

  /// No description provided for @serviceNotRunning.
  ///
  /// In en, this message translates to:
  /// **'Service is not running'**
  String get serviceNotRunning;

  /// No description provided for @connectToViewProxies.
  ///
  /// In en, this message translates to:
  /// **'Connect to view proxies'**
  String get connectToViewProxies;

  /// No description provided for @sortByPing.
  ///
  /// In en, this message translates to:
  /// **'Sort by ping'**
  String get sortByPing;

  /// No description provided for @refreshPing.
  ///
  /// In en, this message translates to:
  /// **'Refresh ping'**
  String get refreshPing;

  /// No description provided for @editConfig.
  ///
  /// In en, this message translates to:
  /// **'Edit Config'**
  String get editConfig;

  /// No description provided for @deleteConfig.
  ///
  /// In en, this message translates to:
  /// **'Delete Config'**
  String get deleteConfig;

  /// No description provided for @configRemark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get configRemark;

  /// No description provided for @configAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get configAddress;

  /// No description provided for @configPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get configPort;

  /// No description provided for @configUuid.
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get configUuid;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @customization.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customization;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @connectionMode.
  ///
  /// In en, this message translates to:
  /// **'Connection Mode'**
  String get connectionMode;

  /// No description provided for @connectionModeProxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get connectionModeProxy;

  /// No description provided for @connectionModeVpn.
  ///
  /// In en, this message translates to:
  /// **'VPN'**
  String get connectionModeVpn;

  /// No description provided for @coreType.
  ///
  /// In en, this message translates to:
  /// **'Core Type'**
  String get coreType;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @restoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore to default'**
  String get restoreDefaults;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @mainSettings.
  ///
  /// In en, this message translates to:
  /// **'Main Settings'**
  String get mainSettings;

  /// No description provided for @connectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully'**
  String get connectionSuccess;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSavedSuccess;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @addingProfile.
  ///
  /// In en, this message translates to:
  /// **'Adding profile'**
  String get addingProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get deleteProfileConfirm;

  /// No description provided for @deleteProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteProfileMessage(String name);

  /// No description provided for @newProfile.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get newProfile;

  /// No description provided for @updateSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Update Subscriptions'**
  String get updateSubscriptions;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @exportSubLink.
  ///
  /// In en, this message translates to:
  /// **'Export subscription link to clipboard'**
  String get exportSubLink;

  /// No description provided for @qrCodeSubLink.
  ///
  /// In en, this message translates to:
  /// **'QR Code subscription link'**
  String get qrCodeSubLink;

  /// No description provided for @addConfigToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Add config to clipboard'**
  String get addConfigToClipboard;

  /// No description provided for @addNewProfile.
  ///
  /// In en, this message translates to:
  /// **'Add new profile'**
  String get addNewProfile;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all configs?'**
  String get deleteAllConfirm;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(String days);

  /// No description provided for @unlimitedDays.
  ///
  /// In en, this message translates to:
  /// **'∞ days remaining'**
  String get unlimitedDays;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @startWithProfile.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a subscription profile'**
  String get startWithProfile;

  /// No description provided for @localConfigs.
  ///
  /// In en, this message translates to:
  /// **'Local Configs'**
  String get localConfigs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
