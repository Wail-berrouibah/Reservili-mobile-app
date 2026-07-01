// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Reservili';

  @override
  String get appTagline => 'Gestion des réservations';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get accessCodePrompt =>
      'Entrez le code d\'accès fourni par le propriétaire.';

  @override
  String get codeBoundToPhone => 'Ce code est lié à votre téléphone.';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get invalidCode => 'Code invalide';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get homes => 'Logements';

  @override
  String get reservations => 'Réservations';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get availability => 'Disponibilité';

  @override
  String get add => 'Ajouter';

  @override
  String get recentReservations => 'Réservations récentes';

  @override
  String get noReservations => 'Aucune réservation';

  @override
  String get upcomingReservationsHint =>
      'Les réservations à venir apparaîtront ici.';

  @override
  String get book => 'Réserver';

  @override
  String get noHomes => 'Aucun logement';

  @override
  String get addFirstHome => 'Ajoutez votre premier logement.';

  @override
  String get homeDetails => 'Détails du logement';

  @override
  String get homeNotFound => 'Logement introuvable';

  @override
  String persons(int count) {
    return '$count personnes';
  }

  @override
  String pricePerNight(String price) {
    return '$price DA / nuit';
  }

  @override
  String get createReservation => 'Créer une réservation';

  @override
  String get activeReservationsNone => 'Aucune réservation active.';

  @override
  String get addHome => 'Ajouter un logement';

  @override
  String get name => 'Nom';

  @override
  String get location => 'Localisation';

  @override
  String get capacity => 'Capacité';

  @override
  String get pricePerNightLabel => 'Prix par nuit (DA)';

  @override
  String get save => 'Enregistrer';

  @override
  String get required => 'Champ requis';

  @override
  String get invalidValue => 'Valeur invalide';

  @override
  String get chooseDates => 'Choisir les dates';

  @override
  String get search => 'Rechercher';

  @override
  String get noHomesAvailable => 'Aucun logement disponible';

  @override
  String get tryOtherDates => 'Essayez d\'autres dates.';

  @override
  String get newReservation => 'Nouvelle réservation';

  @override
  String get home => 'Logement';

  @override
  String get chooseHome => 'Veuillez choisir un logement';

  @override
  String get guestName => 'Nom du client';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneRequired => 'Numéro requis';

  @override
  String get invalidPhone => 'Numéro invalide';

  @override
  String get emailOptional => 'Email (optionnel)';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get guestsCount => 'Nombre de personnes';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get confirmReservation => 'Confirmer la réservation';

  @override
  String get reservationCreated => 'Réservation créée.';

  @override
  String get datesUnavailable => 'Ces dates ne sont pas disponibles.';

  @override
  String get invalidDates => 'Dates invalides.';

  @override
  String get reservationDetails => 'Détails de la réservation';

  @override
  String get reservationNotFound => 'Réservation introuvable';

  @override
  String get arrival => 'Arrivée';

  @override
  String get departure => 'Départ';

  @override
  String get nights => 'Nuits';

  @override
  String get personsLabel => 'Personnes';

  @override
  String get notes => 'Notes';

  @override
  String get confirm => 'Confirmer';

  @override
  String get reschedule => 'Reprogrammer';

  @override
  String get cancelReservation => 'Annuler la réservation';

  @override
  String get cancelConfirmTitle => 'Annuler la réservation ?';

  @override
  String get cancelConfirmBody => 'Cette action est définitive.';

  @override
  String get no => 'Non';

  @override
  String get yesCancel => 'Oui, annuler';

  @override
  String get newDates => 'Nouvelles dates';

  @override
  String get reservationRescheduled => 'Réservation reprogrammée.';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get about => 'À propos';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusConfirmed => 'Confirmée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get client => 'Client';

  @override
  String get calendar => 'Calendrier';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String availableRooms(int count) {
    return '$count logements disponibles';
  }

  @override
  String occupiedRooms(int count) {
    return '$count logements occupés';
  }

  @override
  String get reservedDays => 'Jours réservés';

  @override
  String get gapWarning =>
      'Impossible de laisser un jour vide entre deux réservations.';

  @override
  String get reminderTitle => 'Rappel de réservation';

  @override
  String reservationEndsTomorrow(String home) {
    return 'La réservation de $home se termine demain';
  }
}
