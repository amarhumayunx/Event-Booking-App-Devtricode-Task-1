import 'package:firebase_database/firebase_database.dart';
import '../models/booking.dart';
import '../models/payment.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static const String bookingsPath = 'bookings';
  static const String paymentsPath = 'payments';

  // Create a booking
  static Future<Booking> createBooking(Booking booking) async {
    try {
      final bookingData = booking.toJson();
      // Remove id from data as Firebase will generate it
      bookingData.remove('id');

      final bookingsRef = _database.child(bookingsPath);
      final newBookingRef = bookingsRef.push();
      await newBookingRef.set(bookingData);

      // Get the generated key (id)
      final snapshot = await newBookingRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = newBookingRef.key;
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Get all bookings
  static Future<List<Booking>> getBookings() async {
    try {
      final snapshot = await _database.child(bookingsPath).get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return [];
      }

      final List<Booking> bookings = [];
      data.forEach((key, value) {
        try {
          final bookingData = Map<String, dynamic>.from(value as Map);
          bookingData['id'] = key.toString();
          bookings.add(Booking.fromJson(bookingData));
        } catch (e) {
          print('Error parsing booking $key: $e');
        }
      });

      // Sort by bookingDate descending (newest first)
      bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

      return bookings;
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Delete a booking by ID
  static Future<bool> deleteBooking(String bookingId) async {
    try {
      await _database.child(bookingsPath).child(bookingId).remove();
      return true;
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }

  // Delete all bookings
  static Future<int> deleteAllBookings() async {
    try {
      final snapshot = await _database.child(bookingsPath).get();

      if (!snapshot.exists) {
        return 0;
      }

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return 0;
      }

      final int count = data.length;
      await _database.child(bookingsPath).remove();
      return count;
    } catch (e) {
      throw Exception('Error deleting all bookings: $e');
    }
  }

  // Create a payment
  static Future<Payment> createPayment(Payment payment) async {
    try {
      final paymentData = payment.toJson();
      // Remove id from data as Firebase will generate it
      paymentData.remove('id');

      final paymentsRef = _database.child(paymentsPath);
      final newPaymentRef = paymentsRef.push();
      await newPaymentRef.set(paymentData);

      // Get the generated key (id)
      final snapshot = await newPaymentRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = newPaymentRef.key;
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to create payment');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }
}
