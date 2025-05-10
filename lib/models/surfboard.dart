class Surfboard {
  final int id;
  final String name;
  final bool available;
  final bool damaged;
  final bool shopOwned;
  final String? imageUrl;

  Surfboard({
    required this.id,
    required this.name,
    required this.available,
    required this.damaged,
    required this.shopOwned,
    this.imageUrl,
  });

  factory Surfboard.fromJson(Map<String, dynamic> json) {
    return Surfboard(
      id: json['id'],
      name: json['name'],
      available: json['available'],
      damaged: json['damaged'],
      shopOwned: json['shopOwned'],
      imageUrl: json['imageUrl'],
    );
  }
}
