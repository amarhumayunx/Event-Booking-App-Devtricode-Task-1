class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String address;
  final int price;
  final String image;
  final String category;
  final int availableSeats;
  final int totalSeats;
  final String organizer;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.address,
    required this.price,
    required this.image,
    required this.category,
    required this.availableSeats,
    required this.totalSeats,
    required this.organizer,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      availableSeats: json['availableSeats'] is int ? json['availableSeats'] : int.tryParse(json['availableSeats']?.toString() ?? '0') ?? 0,
      totalSeats: json['totalSeats'] is int ? json['totalSeats'] : int.tryParse(json['totalSeats']?.toString() ?? '0') ?? 0,
      organizer: json['organizer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'address': address,
      'price': price,
      'image': image,
      'category': category,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'organizer': organizer,
    };
  }
}

