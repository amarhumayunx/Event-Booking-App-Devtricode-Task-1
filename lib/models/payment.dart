class Payment {
  final String? id;
  final String bookingId;
  final String eventId;
  final String eventName;
  final String amount;
  final String currency;
  final String paymentMethod;
  final String transactionId;
  final String paymentStatus;
  final String paymentDate;
  final bool isTestPayment;

  Payment({
    this.id,
    required this.bookingId,
    required this.eventId,
    required this.eventName,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentStatus,
    required this.paymentDate,
    required this.isTestPayment,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString(),
      bookingId: json['bookingId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventName: json['eventName'] ?? '',
      amount: json['amount']?.toString() ?? '',
      currency: json['currency'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentDate: json['paymentDate'] ?? '',
      isTestPayment: json['isTestPayment'] is bool
          ? json['isTestPayment']
          : json['isTestPayment']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bookingId': bookingId,
      'eventId': eventId,
      'eventName': eventName,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate,
      'isTestPayment': isTestPayment,
    };
  }
}

