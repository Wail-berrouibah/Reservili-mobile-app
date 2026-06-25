import '../shared/models/home_model.dart';
import '../shared/models/guest_model.dart';
import '../shared/models/reservation_model.dart';

class MockData {
  MockData._();

  static List<HomeModel> get sampleHomes => [
        HomeModel(
          id: '1',
          name: 'Beach Villa',
          description: 'Beautiful beachfront villa with stunning ocean views.',
          address: '123 Coastal Road, Malibu',
          pricePerNight: 250,
          maxGuests: 6,
        ),
        HomeModel(
          id: '2',
          name: 'Mountain Cabin',
          description: 'Cozy cabin nestled in the mountains.',
          address: '45 Pine Trail, Aspen',
          pricePerNight: 180,
          maxGuests: 4,
        ),
        HomeModel(
          id: '3',
          name: 'City Apartment',
          description: 'Modern apartment in the heart of the city.',
          address: '78 Urban Street, New York',
          pricePerNight: 200,
          maxGuests: 3,
        ),
        HomeModel(
          id: '4',
          name: 'Lake House',
          description: 'Peaceful lake house with a private dock.',
          address: '12 Lakeview Drive, Lake Tahoe',
          pricePerNight: 300,
          maxGuests: 8,
        ),
      ];

  static List<ReservationModel> get sampleReservations => [
        ReservationModel(
          id: 'r1',
          homeId: '1',
          guest: const GuestModel(
            name: 'John Smith',
            phone: '+1 555-0101',
            email: 'john@email.com',
          ),
          checkIn: DateTime.now().add(const Duration(days: 5)),
          checkOut: DateTime.now().add(const Duration(days: 8)),
        ),
        ReservationModel(
          id: 'r2',
          homeId: '2',
          guest: const GuestModel(
            name: 'Sarah Johnson',
            phone: '+1 555-0102',
            email: 'sarah@email.com',
          ),
          checkIn: DateTime.now().add(const Duration(days: 10)),
          checkOut: DateTime.now().add(const Duration(days: 15)),
        ),
      ];
}
