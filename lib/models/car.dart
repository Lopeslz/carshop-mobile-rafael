class Car {
  final String imageUrl;
  final String title;
  final String price;
  final String year;
  final String mileage;
  final String variant;
  final int id;
  final String sellerId;
  final double meetingLat;
  final double meetingLng;
  final DateTime createdAt;

  Car({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.year,
    required this.mileage,
    required this.variant,
    required this.id,
    required this.sellerId,
    required this.meetingLat,
    required this.meetingLng,
    required this.createdAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      year: json['year'] ?? '',
      mileage: json['mileage'] ?? '',
      variant: json['variant'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      meetingLat: (json['meetingLat'] ?? 0).toDouble(),
      meetingLng: (json['meetingLng'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      sellerId: (json['seller']?['id'] ?? json['sellerId'] ?? 0).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'year': year,
      'mileage': mileage,
      'variant': variant,
      'imageUrl': imageUrl,
      'meetingLat': meetingLat,
      'meetingLng': meetingLng,
      'createdAt': createdAt.toIso8601String(),
      'sellerId': sellerId,
    };
  }
}
