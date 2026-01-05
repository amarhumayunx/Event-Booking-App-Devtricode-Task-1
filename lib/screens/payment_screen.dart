import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event.dart';
import '../models/payment.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Event event;
  final int numberOfTickets;
  final int totalPrice;
  final String userName;
  final String userEmail;
  final String userPhone;

  const PaymentScreen({
    super.key,
    required this.event,
    required this.numberOfTickets,
    required this.totalPrice,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  bool _isProcessing = false;
  bool _paymentSuccessful = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prefillCardDetails();
  }

  void _prefillCardDetails() {
    _cardNumberController.text = '4242 4242 4242 4242';
    _expiryDateController.text = '12/25';
    _cvvController.text = '123';
    _cardholderNameController.text = widget.userName;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String input) {
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += digitsOnly[i];
    }
    return formatted;
  }

  String _formatExpiryDate(String input) {
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 2) {
      return '${digitsOnly.substring(0, 2)}/${digitsOnly.length > 2 ? digitsOnly.substring(2, 4) : ''}';
    }
    return digitsOnly;
  }

  void _validateRequiredFields() {
    if (widget.event.id.isEmpty) throw Exception('Event ID is missing');
    if (widget.userName.trim().isEmpty) throw Exception('User name is required');
    if (widget.userEmail.trim().isEmpty) throw Exception('User email is required');
    if (widget.userPhone.trim().isEmpty) throw Exception('User phone is required');
    if (widget.numberOfTickets <= 0) throw Exception('Number of tickets must be greater than 0');
  }

  Booking _createBooking() {
    return Booking(
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      eventDate: widget.event.date,
      eventTime: widget.event.time,
      eventLocation: widget.event.location,
      numberOfTickets: widget.numberOfTickets,
      totalPrice: widget.totalPrice,
      userName: widget.userName.trim(),
      userEmail: widget.userEmail.trim(),
      userPhone: widget.userPhone.trim(),
      bookingDate: DateTime.now().toIso8601String(),
    );
  }

  Payment _createPayment(String bookingId) {
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    return Payment(
      bookingId: bookingId,
      eventId: widget.event.id,
      eventName: widget.event.title,
      amount: widget.totalPrice.toString(),
      currency: 'PKR',
      paymentMethod: 'VISA',
      transactionId: transactionId,
      paymentStatus: 'success',
      paymentDate: DateTime.now().toIso8601String(),
      isTestPayment: true,
    );
  }

  String _parseErrorMessage(dynamic error) {
    String fullError = error.toString();

    if (fullError.contains('MockAPI limit') || fullError.contains('Max number of elements')) {
      return 'Storage limit reached. Please delete old bookings and try again.';
    }

    if (fullError.contains('400')) {
      return _parse400Error(fullError);
    }

    final statusErrors = {
      '401': 'Authentication failed. Please try again.',
      '403': 'Access denied. Please check your permissions.',
      '404': 'Service not found. Please try again later.',
      '500': 'Server error. Please try again later.',
    };

    for (var entry in statusErrors.entries) {
      if (fullError.contains(entry.key)) return entry.value;
    }

    if (fullError.contains('SocketException') || fullError.contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }

    if (fullError.contains('Exception')) {
      return _cleanErrorMessage(fullError.replaceAll('Exception: ', ''));
    }

    return _cleanErrorMessage(fullError);
  }

  String _parse400Error(String fullError) {
    if (!fullError.contains('Status 400:')) {
      return 'Failed to create booking. Please check your details and try again.';
    }

    String errorMessage = fullError.split('Status 400:').last.trim();
    errorMessage = errorMessage.replaceAll('"', '');

    if (errorMessage.contains('Max number of elements')) {
      return 'Storage limit reached. Please delete old bookings and try again.';
    }

    if (errorMessage.isEmpty || errorMessage.length > 100) {
      return 'Failed to create booking. Please check your details and try again.';
    }

    return errorMessage;
  }

  String _cleanErrorMessage(String message) {
    return message.length > 150 ? '${message.substring(0, 147)}...' : message;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Payment Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _paymentSuccessful = false;
    });

    try {
      UserService.setCurrentUserEmail(widget.userEmail);
      _validateRequiredFields();

      final booking = _createBooking();
      final createdBooking = await ApiService.createBooking(booking);

      if (createdBooking.id == null || createdBooking.id!.isEmpty) {
        throw Exception('Booking created but no ID returned from server');
      }

      final payment = _createPayment(createdBooking.id!);
      await ApiService.createPayment(payment);

      setState(() {
        _paymentSuccessful = true;
        _isProcessing = false;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Get.offAll(
          () => BookingConfirmationScreen(booking: createdBooking),
          transition: Transition.zoom,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);

      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
        _paymentSuccessful = false;
      });

      _showErrorSnackbar(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 24),
              _buildPaymentMethod(),
              const SizedBox(height: 24),
              _buildCardDetailsForm(),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 16),
              ],
              if (_paymentSuccessful) ...[
                _buildSuccessMessage(),
                const SizedBox(height: 16),
              ],
              _buildPayButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.numberOfTickets} x Rs. ${widget.event.price}',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey[800]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Rs. ${widget.totalPrice}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VISA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Credit/Debit Card',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildCardNumberField(),
        const SizedBox(height: 16),
        _buildCardholderNameField(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildExpiryDateField()),
            const SizedBox(width: 16),
            Expanded(child: _buildCvvField()),
          ],
        ),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        label: 'Card Number',
        hint: '4242 4242 4242 4242',
        icon: Icons.credit_card,
      ),
      keyboardType: TextInputType.number,
      maxLength: 19,
      onChanged: (value) {
        final formatted = _formatCardNumber(value);
        if (formatted != value) {
          _cardNumberController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter card number';
        final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length != 16) return 'Card number must be 16 digits';
        if (!digitsOnly.startsWith('4')) return 'VISA card must start with 4';
        return null;
      },
    );
  }

  Widget _buildCardholderNameField() {
    return TextFormField(
      controller: _cardholderNameController,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        label: 'Cardholder Name',
        hint: 'Enter cardholder name',
        icon: Icons.person,
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter cardholder name';
        return null;
      },
    );
  }

  Widget _buildExpiryDateField() {
    return TextFormField(
      controller: _expiryDateController,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        label: 'Expiry Date',
        hint: 'MM/YY',
        icon: Icons.calendar_today,
      ),
      keyboardType: TextInputType.number,
      maxLength: 5,
      onChanged: (value) {
        final formatted = _formatExpiryDate(value);
        if (formatted != value) {
          _expiryDateController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (value.length != 5) return 'Invalid format';
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      controller: _cvvController,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        label: 'CVV',
        hint: '123',
        icon: Icons.lock,
      ),
      keyboardType: TextInputType.number,
      maxLength: 3,
      obscureText: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (value.length != 3) return 'Invalid CVV';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: Colors.red),
      filled: true,
      fillColor: Colors.grey[900],
      counterStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          SizedBox(width: 12),
          Text(
            'Payment Successful!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (_isProcessing || _paymentSuccessful) ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: Colors.grey[800],
        ),
        child: _isProcessing
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Pay Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}