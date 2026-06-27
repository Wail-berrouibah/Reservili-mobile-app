import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reservili'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des réservations'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcome;

  /// No description provided for @accessCodePrompt.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code d\'accès fourni par le propriétaire.'**
  String get accessCodePrompt;

  /// No description provided for @codeBoundToPhone.
  ///
  /// In fr, this message translates to:
  /// **'Ce code est lié à votre téléphone.'**
  String get codeBoundToPhone;

  /// No description provided for @continueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueLabel;

  /// No description provided for @invalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide'**
  String get invalidCode;

  /// No description provided for @connectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get connectionError;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @homes.
  ///
  /// In fr, this message translates to:
  /// **'Logements'**
  String get homes;

  /// No description provided for @reservations.
  ///
  /// In fr, this message translates to:
  /// **'Réservations'**
  String get reservations;

  /// No description provided for @quickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActions;

  /// No description provided for @availability.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité'**
  String get availability;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @recentReservations.
  ///
  /// In fr, this message translates to:
  /// **'Réservations récentes'**
  String get recentReservations;

  /// No description provided for @noReservations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation'**
  String get noReservations;

  /// No description provided for @upcomingReservationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les réservations à venir apparaîtront ici.'**
  String get upcomingReservationsHint;

  /// No description provided for @book.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get book;

  /// No description provided for @noHomes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun logement'**
  String get noHomes;

  /// No description provided for @addFirstHome.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier logement.'**
  String get addFirstHome;

  /// No description provided for @homeDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du logement'**
  String get homeDetails;

  /// No description provided for @homeNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Logement introuvable'**
  String get homeNotFound;

  /// No description provided for @persons.
  ///
  /// In fr, this message translates to:
  /// **'{count} personnes'**
  String persons(int count);

  /// No description provided for @pricePerNight.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA / nuit'**
  String pricePerNight(String price);

  /// No description provided for @createReservation.
  ///
  /// In fr, this message translates to:
  /// **'Créer une réservation'**
  String get createReservation;

  /// No description provided for @activeReservationsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation active.'**
  String get activeReservationsNone;

  /// No description provided for @addHome.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un logement'**
  String get addHome;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @location.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get location;

  /// No description provided for @capacity.
  ///
  /// In fr, this message translates to:
  /// **'Capacité'**
  String get capacity;

  /// No description provided for @pricePerNightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix par nuit (DA)'**
  String get pricePerNightLabel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get required;

  /// No description provided for @invalidValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur invalide'**
  String get invalidValue;

  /// No description provided for @chooseDates.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les dates'**
  String get chooseDates;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @noHomesAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun logement disponible'**
  String get noHomesAvailable;

  /// No description provided for @tryOtherDates.
  ///
  /// In fr, this message translates to:
  /// **'Essayez d\'autres dates.'**
  String get tryOtherDates;

  /// No description provided for @newReservation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réservation'**
  String get newReservation;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Logement'**
  String get home;

  /// No description provided for @chooseHome.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez choisir un logement'**
  String get chooseHome;

  /// No description provided for @guestName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du client'**
  String get guestName;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @phoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Numéro requis'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide'**
  String get invalidPhone;

  /// No description provided for @emailOptional.
  ///
  /// In fr, this message translates to:
  /// **'Email (optionnel)'**
  String get emailOptional;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @guestsCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes'**
  String get guestsCount;

  /// No description provided for @notesOptional.
  ///
  /// In fr, this message translates to:
  /// **'Notes (optionnel)'**
  String get notesOptional;

  /// No description provided for @confirmReservation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la réservation'**
  String get confirmReservation;

  /// No description provided for @reservationCreated.
  ///
  /// In fr, this message translates to:
  /// **'Réservation créée.'**
  String get reservationCreated;

  /// No description provided for @datesUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ces dates ne sont pas disponibles.'**
  String get datesUnavailable;

  /// No description provided for @invalidDates.
  ///
  /// In fr, this message translates to:
  /// **'Dates invalides.'**
  String get invalidDates;

  /// No description provided for @reservationDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la réservation'**
  String get reservationDetails;

  /// No description provided for @reservationNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Réservation introuvable'**
  String get reservationNotFound;

  /// No description provided for @arrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée'**
  String get arrival;

  /// No description provided for @departure.
  ///
  /// In fr, this message translates to:
  /// **'Départ'**
  String get departure;

  /// No description provided for @nights.
  ///
  /// In fr, this message translates to:
  /// **'Nuits'**
  String get nights;

  /// No description provided for @personsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Personnes'**
  String get personsLabel;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @reschedule.
  ///
  /// In fr, this message translates to:
  /// **'Reprogrammer'**
  String get reschedule;

  /// No description provided for @cancelReservation.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation'**
  String get cancelReservation;

  /// No description provided for @cancelConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation ?'**
  String get cancelConfirmTitle;

  /// No description provided for @cancelConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est définitive.'**
  String get cancelConfirmBody;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get yesCancel;

  /// No description provided for @newDates.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles dates'**
  String get newDates;

  /// No description provided for @reservationRescheduled.
  ///
  /// In fr, this message translates to:
  /// **'Réservation reprogrammée.'**
  String get reservationRescheduled;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get statusCancelled;

  /// No description provided for @client.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @reminderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de réservation'**
  String get reminderTitle;

  /// No description provided for @reservationEndsTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'La réservation de {home} se termine demain'**
  String reservationEndsTomorrow(String home);
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
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
