class Booking {
  final String? id;
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final int numberOfTickets;
  final int totalPrice;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String bookingDate;

  Booking({
    this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.numberOfTickets,
    required this.totalPrice,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.bookingDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      eventId: json['eventId'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      eventDate: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '',
      eventLocation: json['eventLocation'] ?? '',
      numberOfTickets: json['numberOfTickets'] is int 
          ? json['numberOfTickets'] 
          : int.tryParse(json['numberOfTickets']?.toString() ?? '0') ?? 0,
      totalPrice: json['totalPrice'] is int 
          ? json['totalPrice'] 
          : int.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0,
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventLocation': eventLocation,
      'numberOfTickets': numberOfTickets,
      'totalPrice': totalPrice,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'bookingDate': bookingDate,
    };
  }
}

