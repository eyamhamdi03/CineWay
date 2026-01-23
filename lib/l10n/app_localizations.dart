import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @dark_mode_sub.
  ///
  /// In en, this message translates to:
  /// **'Toggle app theme'**
  String get dark_mode_sub;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @language_sub.
  ///
  /// In en, this message translates to:
  /// **'English / Français'**
  String get language_sub;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @payment_methods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get payment_methods;

  /// No description provided for @purchase_history.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchase_history;

  /// No description provided for @support_legal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get support_legal;

  /// No description provided for @help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get log_out;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @create_profile.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get create_profile;

  /// No description provided for @complete_profile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get complete_profile;

  /// No description provided for @booking_title.
  ///
  /// In en, this message translates to:
  /// **'Your Ticket'**
  String get booking_title;

  /// No description provided for @booking_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get booking_confirmed;

  /// No description provided for @add_to_calendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get add_to_calendar;

  /// No description provided for @view_receipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get view_receipt;

  /// No description provided for @view_bookings.
  ///
  /// In en, this message translates to:
  /// **'View My Bookings'**
  String get view_bookings;

  /// No description provided for @back_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get back_home;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @buy_tickets.
  ///
  /// In en, this message translates to:
  /// **'Buy Tickets'**
  String get buy_tickets;

  /// No description provided for @continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button;

  /// No description provided for @proceed_payment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceed_payment;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome_back;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @sign_in_failed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get sign_in_failed;

  /// No description provided for @select_seats.
  ///
  /// In en, this message translates to:
  /// **'Select Seats'**
  String get select_seats;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @maximum_seats_selected.
  ///
  /// In en, this message translates to:
  /// **'Maximum seats selected'**
  String get maximum_seats_selected;

  /// No description provided for @please_select_seat.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one seat'**
  String get please_select_seat;

  /// No description provided for @your_ticket_scan_qr.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code below for entry.'**
  String get your_ticket_scan_qr;

  /// No description provided for @notification_settings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notification_settings;

  /// No description provided for @customize_notifications.
  ///
  /// In en, this message translates to:
  /// **'Customize your notification preferences'**
  String get customize_notifications;

  /// No description provided for @activity_alerts.
  ///
  /// In en, this message translates to:
  /// **'Activity Alerts'**
  String get activity_alerts;

  /// No description provided for @marketing_updates.
  ///
  /// In en, this message translates to:
  /// **'Marketing & Updates'**
  String get marketing_updates;

  /// No description provided for @new_movies.
  ///
  /// In en, this message translates to:
  /// **'New Movies'**
  String get new_movies;

  /// No description provided for @new_movies_desc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when new movies are available'**
  String get new_movies_desc;

  /// No description provided for @showtime_reminders.
  ///
  /// In en, this message translates to:
  /// **'Showtime Reminders'**
  String get showtime_reminders;

  /// No description provided for @showtime_reminders_desc.
  ///
  /// In en, this message translates to:
  /// **'Reminders before your movie starts'**
  String get showtime_reminders_desc;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @promotions_desc.
  ///
  /// In en, this message translates to:
  /// **'Exclusive offers and discounts'**
  String get promotions_desc;

  /// No description provided for @ticket_updates.
  ///
  /// In en, this message translates to:
  /// **'Ticket Updates'**
  String get ticket_updates;

  /// No description provided for @ticket_updates_desc.
  ///
  /// In en, this message translates to:
  /// **'Changes to your bookings'**
  String get ticket_updates_desc;

  /// No description provided for @critical_alerts.
  ///
  /// In en, this message translates to:
  /// **'Critical System Alerts'**
  String get critical_alerts;

  /// No description provided for @critical_alerts_text.
  ///
  /// In en, this message translates to:
  /// **'Critical system alerts about your account security and payment issues cannot be disabled'**
  String get critical_alerts_text;

  /// No description provided for @saved_cards.
  ///
  /// In en, this message translates to:
  /// **'Saved Cards'**
  String get saved_cards;

  /// No description provided for @add_new_method.
  ///
  /// In en, this message translates to:
  /// **'Add New Method'**
  String get add_new_method;

  /// No description provided for @other_options.
  ///
  /// In en, this message translates to:
  /// **'Other Options'**
  String get other_options;

  /// No description provided for @transaction_history.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transaction_history;

  /// No description provided for @redeem_gift_card.
  ///
  /// In en, this message translates to:
  /// **'Redeem Gift Card'**
  String get redeem_gift_card;

  /// No description provided for @search_transactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get search_transactions;

  /// No description provided for @total_spent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get total_spent;

  /// No description provided for @load_older_transactions.
  ///
  /// In en, this message translates to:
  /// **'Load older transactions'**
  String get load_older_transactions;

  /// No description provided for @ticket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticket;

  /// No description provided for @search_for_help.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get search_for_help;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @popular_faqs.
  ///
  /// In en, this message translates to:
  /// **'Popular FAQs'**
  String get popular_faqs;

  /// No description provided for @still_need_help.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get still_need_help;

  /// No description provided for @support_team_available.
  ///
  /// In en, this message translates to:
  /// **'Our support team is available 24/7 to assist you with any inquiries.'**
  String get support_team_available;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
