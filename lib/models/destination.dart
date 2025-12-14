class Destination {
  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final double rating;
  final String description;

  Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? 'Unknown',
      country: json['country'] ?? json['location'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['photo'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      description: json['description'] ?? '',
    );
  }
}
