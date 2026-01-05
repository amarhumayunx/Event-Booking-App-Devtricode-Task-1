import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import 'firebase_service.dart';

class ApiService {
  static const String baseUrl =
      'https://6957cd11f7ea690182d320ba.mockapi.io/events';
  static const String eventsEndpoint =
      'https://mocki.io/v1/1bb09959-5133-4bce-b26d-25182db47bed';
  static const String bookingsEndpoint = '$baseUrl/bookings';
  static const String paymentBaseUrl =
      'https://695a4db8950475ada4665f19.mockapi.io/paymeny';
  static const String paymentEndpoint = '$paymentBaseUrl/booking';

  // Fetch all events
  static Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse(eventsEndpoint));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } else if (response.statusCode == 503) {
        throw Exception(
          'Service temporarily unavailable. Please try again later.',
        );
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('503') ||
          e.toString().contains('Service temporarily unavailable')) {
        rethrow;
      }
      throw Exception('Error fetching events: $e');
    }
  }

  // Create a booking (using Firebase)
  static Future<Booking> createBooking(Booking booking) async {
    try {
      return await FirebaseService.createBooking(booking);
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Get all bookings (using Firebase)
  static Future<List<Booking>> getBookings() async {
    try {
      return await FirebaseService.getBookings();
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Delete a booking by ID (using Firebase)
  static Future<bool> deleteBooking(String bookingId) async {
    try {
      return await FirebaseService.deleteBooking(bookingId);
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }

  // Delete all bookings (using Firebase)
  static Future<int> deleteAllBookings() async {
    try {
      return await FirebaseService.deleteAllBookings();
    } catch (e) {
      throw Exception('Error deleting all bookings: $e');
    }
  }

  // Create a payment (using Firebase)
  static Future<Payment> createPayment(Payment payment) async {
    try {
      return await FirebaseService.createPayment(payment);
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }
}
