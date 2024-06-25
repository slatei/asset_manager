class Asset {
  final String? id;
  final String name;
  final String category;
  final String purchaseDate;
  final double cost;
  final String? photoPath;

  Asset({
    this.id,
    required this.name,
    required this.category,
    required this.purchaseDate,
    required this.cost,
    this.photoPath,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Un-categorized',
      purchaseDate: json['purchaseDate'] ?? 'Unknown',
      cost: (json['cost'] ?? 0).toDouble(),
      photoPath: json['photoPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'purchase_date': purchaseDate,
      'cost': cost,
      'photo_path': photoPath,
    };
  }
}
