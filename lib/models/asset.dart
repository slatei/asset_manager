class Asset {
  final String? id;
  final String name;
  final String category;
  final String? purchaseDate;
  final double cost;
  final String? photoPath;
  final List<String>? labels;

  Asset({
    this.id,
    required this.name,
    required this.category,
    this.purchaseDate,
    required this.cost,
    this.photoPath,
    this.labels,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Un-categorized',
      purchaseDate: json['purchaseDate'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      photoPath: json['photoPath'],
      labels: json['labels'],
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
      'labels': labels,
    };
  }
}
