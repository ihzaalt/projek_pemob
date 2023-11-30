class KostData {
  final String id;
  final String name;
  final String price;
  final String description;
  final String image;

  KostData({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  // Add factory method to convert JSON to KostData
  factory KostData.fromJson(Map<String, dynamic> json) {
    return KostData(
      id: json['id'] ?? '',
      name: json['name'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
    );
  }

  // Convert KostData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
    };
  }
}
