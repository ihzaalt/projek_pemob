class KostData {
  final String name;
  final int price;
  final String description;
  final String image;
  final String id;

  KostData({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.id,
  });

  // Tambahkan factory method untuk konversi dari JSON
  factory KostData.fromJson(Map<String, dynamic> json) {
    return KostData(
      name: json['name'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
      id: json['id'],
    );
  }

  // Tambahkan method toJson untuk konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'id': id,
    };
  }
}
