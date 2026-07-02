import '../shared/models/home_model.dart';
import '../shared/models/guest_model.dart';
import '../shared/models/reservation_model.dart';

/// Temporary in-memory data for development.
/// Replace with real API calls once the backend is connected.
class MockData {
  MockData._();

  static final List<HomeModel> homes = [
    const HomeModel(
      id: 'h1',
      name: 'Villa Jardin',
      location: 'Alger Centre',
      capacity: 6,
      pricePerNight: 12000,
    ),
    const HomeModel(
      id: 'h2',
      name: 'Appartement Marina',
      location: 'Oran',
      capacity: 4,
      pricePerNight: 8500,
    ),
    const HomeModel(
      id: 'h3',
      name: 'Maison Olivier',
      location: 'Tizi Ouzou',
      capacity: 8,
      pricePerNight: 15000,
    ),
  ];

  static final List<GuestModel> guests = [
    const GuestModel(
      id: 'g1',
      fullName: 'Amine Belkacem',
      phone: '0550 12 34 56',
      email: 'amine@example.com',
    ),
    const GuestModel(
      id: 'g2',
      fullName: 'Sara Haddad',
      phone: '0661 98 76 54',
    ),
  ];

  static List<ReservationModel> reservations() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      ReservationModel(
        id: 'r1',
        homeId: 'h1',
        guestId: 'g1',
        checkInDate: today.add(const Duration(days: 2, hours: 12)),
        checkOutDate: today.add(const Duration(days: 5, hours: 10)),
        guestsCount: 4,
        paidPrice: 48000,
        status: ReservationStatus.confirmed,
        notes: 'Arrivée tôt le matin.',
        createdAt: now,
        updatedAt: now,
      ),
      ReservationModel(
        id: 'r2',
        homeId: 'h2',
        guestId: 'g2',
        checkInDate: today.add(const Duration(days: 7, hours: 12)),
        checkOutDate: today.add(const Duration(days: 9, hours: 10)),
        guestsCount: 2,
        paidPrice: 17000,
        status: ReservationStatus.pending,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
