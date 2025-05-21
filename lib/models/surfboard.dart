class Surfboard {
  final String id;
  final String name;
  final String? description;
  final double? size;
  final String? sizeText;
  final bool available;
  final bool damaged;
  final bool shopOwned;
  final String? imageUrl;

  Surfboard({
    required this.id,
    required this.name,
    this.description,
    this.size,
    this.sizeText,
    required this.available,
    required this.damaged,
    required this.shopOwned,
    this.imageUrl,
  });

  factory Surfboard.fromJson(Map<String, dynamic> json) {
    return Surfboard(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      size: (json['size'] as num?)?.toDouble(),
      sizeText: json['sizeText'] as String?,
      available: json['available'],
      damaged: json['damaged'],
      shopOwned: json['shopOwned'],
      imageUrl: json['imageUrl'],
    );
  }
}
