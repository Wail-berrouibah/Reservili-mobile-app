import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/auth/access_code_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/homes/homes_screen.dart';
import '../../features/homes/add_home_screen.dart';
import '../../features/homes/home_details_screen.dart';
import '../../shared/models/home_model.dart';
import '../../features/availability/search_availability_screen.dart';
import '../../features/reservations/reservations_screen.dart';
import '../../features/reservations/create_reservation_screen.dart';
import '../../features/reservations/reservation_details_screen.dart';
import '../../features/reservations/reschedule_reservation_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const language = '/language';
  static const accessCode = '/access-code';
  static const dashboard = '/dashboard';
  static const homes = '/homes';
  static const addHome = '/homes/add';
  static const homeDetails = '/homes/details';
  static const availability = '/availability';
  static const reservations = '/reservations';
  static const createReservation = '/reservations/create';
  static const reservationDetails = '/reservations/details';
  static const reschedule = '/reservations/reschedule';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(
        path: AppRoutes.language,
        builder: (_, __) => const LanguageScreen()),
    GoRoute(
        path: AppRoutes.accessCode,
        builder: (_, __) => const AccessCodeScreen()),
    GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen()),
    GoRoute(path: AppRoutes.homes, builder: (_, __) => const HomesScreen()),
    GoRoute(
        path: AppRoutes.addHome,
        builder: (_, state) =>
            AddHomeScreen(home: state.extra as HomeModel?)),
    GoRoute(
      path: AppRoutes.homeDetails,
      builder: (_, state) => HomeDetailsScreen(homeId: state.extra as String),
    ),
    GoRoute(
        path: AppRoutes.availability,
        builder: (_, __) => const SearchAvailabilityScreen()),
    GoRoute(
        path: AppRoutes.reservations,
        builder: (_, __) => const ReservationsScreen()),
    GoRoute(
      path: AppRoutes.createReservation,
      builder: (_, state) =>
          CreateReservationScreen(homeId: state.extra as String?),
    ),
    GoRoute(
      path: AppRoutes.reservationDetails,
      builder: (_, state) =>
          ReservationDetailsScreen(reservationId: state.extra as String),
    ),
    GoRoute(
      path: AppRoutes.reschedule,
      builder: (_, state) =>
          RescheduleReservationScreen(reservationId: state.extra as String),
    ),
    GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen()),
  ],
);
