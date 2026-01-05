import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/booking.dart';
import '../models/payment.dart';

class ApiService {
  static const String baseUrl =
      'https://6957cd11f7ea690182d320ba.mockapi.io/events';
  static const String eventsEndpoint = '$baseUrl/events';
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
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  // Create a booking
  static Future<Booking> createBooking(Booking booking) async {
    try {
      // Debug: Print the booking data being sent
      print('Creating booking with data: ${json.encode(booking.toJson())}');
      print('Booking endpoint: $bookingsEndpoint');

      final response = await http.post(
        Uri.parse(bookingsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(booking.toJson()),
      );

      // Debug: Print response details
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        // Try to parse error message from response
        String errorMessage =
            'Failed to create booking: ${response.statusCode}';
        try {
          // Check if response body is a string (like "Max number of elements reached")
          String responseBody = response.body;
          if (responseBody.startsWith('"') && responseBody.endsWith('"')) {
            // Remove quotes from string response
            responseBody = responseBody.substring(1, responseBody.length - 1);
          }

          if (responseBody.contains('Max number of elements')) {
            errorMessage =
                'MockAPI limit reached. Please delete old bookings or use a different API endpoint.';
          } else {
            try {
              final errorData = json.decode(response.body);
              if (errorData is Map && errorData.containsKey('message')) {
                errorMessage = errorData['message'].toString();
              } else if (errorData is Map && errorData.containsKey('error')) {
                errorMessage = errorData['error'].toString();
              } else {
                errorMessage = responseBody;
              }
            } catch (_) {
              errorMessage = responseBody;
            }
          }
        } catch (_) {
          // If parsing fails, include response body
          String responseBody = response.body;
          if (responseBody.startsWith('"') && responseBody.endsWith('"')) {
            responseBody = responseBody.substring(1, responseBody.length - 1);
          }
          if (responseBody.contains('Max number of elements')) {
            errorMessage =
                'MockAPI limit reached. Please delete old bookings or use a different API endpoint.';
          } else {
            errorMessage = 'Status ${response.statusCode}: $responseBody';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Print full error for debugging
      print('Error creating booking: $e');
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Error creating booking: $e');
    }
  }

  // Get all bookings
  static Future<List<Booking>> getBookings() async {
    try {
      final response = await http.get(Uri.parse(bookingsEndpoint));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Delete a booking by ID
  static Future<bool> deleteBooking(String bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse('$bookingsEndpoint/$bookingId'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }

  // Delete all bookings (useful when MockAPI limit is reached)
  static Future<int> deleteAllBookings() async {
    try {
      final bookings = await getBookings();
      int deletedCount = 0;

      for (var booking in bookings) {
        if (booking.id != null) {
          try {
            await deleteBooking(booking.id!);
            deletedCount++;
          } catch (e) {
            print('Failed to delete booking ${booking.id}: $e');
          }
        }
      }

      return deletedCount;
    } catch (e) {
      throw Exception('Error deleting all bookings: $e');
    }
  }

  // Create a payment
  static Future<Payment> createPayment(Payment payment) async {
    try {
      final response = await http.post(
        Uri.parse(paymentEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }
}
