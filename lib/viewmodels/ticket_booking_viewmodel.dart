import '../models/event.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class TicketBookingViewModel extends BaseViewModel {
  final Event event;
  int _numberOfTickets = 1;

  TicketBookingViewModel(this.event);

  int get numberOfTickets => _numberOfTickets;
  int get totalPrice => _numberOfTickets * event.price;
  bool get canIncrement => _numberOfTickets < event.availableSeats;
  bool get canDecrement => _numberOfTickets > 1;

  void incrementTickets() {
    if (_numberOfTickets < event.availableSeats) {
      _numberOfTickets++;
      update();
    }
  }

  void decrementTickets() {
    if (_numberOfTickets > 1) {
      _numberOfTickets--;
      update();
    }
  }

  void setNumberOfTickets(int value) {
    if (value >= 1 && value <= event.availableSeats) {
      _numberOfTickets = value;
      update();
    }
  }

  Future<Booking?> createBooking({
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    setLoading(true);
    clearError();

    try {
      final totalPrice = _numberOfTickets * event.price;
      final bookingDate = DateTime.now().toIso8601String();

      final booking = Booking(
        eventId: event.id,
        eventTitle: event.title,
        eventDate: event.date,
        eventTime: event.time,
        eventLocation: event.location,
        numberOfTickets: _numberOfTickets,
        totalPrice: totalPrice,
        userName: userName.trim(),
        userEmail: userEmail.trim(),
        userPhone: userPhone.trim(),
        bookingDate: bookingDate,
      );

      final createdBooking = await ApiService.createBooking(booking);
      setLoading(false);
      return createdBooking;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return null;
    }
  }
}

