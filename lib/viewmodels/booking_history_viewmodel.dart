import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import 'base_viewmodel.dart';

class BookingHistoryViewModel extends BaseViewModel {
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  String? _userEmail;

  List<Booking> get bookings => _filteredBookings.isEmpty ? _bookings : _filteredBookings;
  List<Booking> get allBookings => _bookings;
  bool get hasBookings => _bookings.isNotEmpty;

  BookingHistoryViewModel({String? userEmail}) {
    _userEmail = userEmail ?? UserService.currentUserEmail;
    loadBookings();
  }

  Future<void> loadBookings() async {
    setLoading(true);
    clearError();

    try {
      final fetchedBookings = await ApiService.getBookings();
      
      // Filter bookings by user email if available
      List<Booking> filtered = fetchedBookings;
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        filtered = fetchedBookings.where((booking) => 
          booking.userEmail.toLowerCase() == _userEmail!.toLowerCase()
        ).toList();
      }
      
      // Sort bookings by booking date (newest first)
      filtered.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      _bookings = filtered;
      _filteredBookings = _bookings;
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  void filterBookings(String query) {
    if (query.isEmpty) {
      _filteredBookings = _bookings;
    } else {
      _filteredBookings = _bookings.where((booking) {
        return booking.eventTitle.toLowerCase().contains(query.toLowerCase()) ||
            booking.userName.toLowerCase().contains(query.toLowerCase()) ||
            booking.userEmail.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  void clearFilter() {
    _filteredBookings = _bookings;
    update();
  }

  Future<bool> deleteBooking(String bookingId) async {
    setLoading(true);
    clearError();

    try {
      final success = await ApiService.deleteBooking(bookingId);
      if (success) {
        // Remove from local list
        _bookings.removeWhere((booking) => booking.id == bookingId);
        _filteredBookings.removeWhere((booking) => booking.id == bookingId);
        setLoading(false);
        update();
        return true;
      }
      setLoading(false);
      return false;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<int> deleteAllBookings() async {
    setLoading(true);
    clearError();

    try {
      final deletedCount = await ApiService.deleteAllBookings();
      // Clear local lists
      _bookings.clear();
      _filteredBookings.clear();
      setLoading(false);
      update();
      return deletedCount;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return 0;
    }
  }
}

