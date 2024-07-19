class Purchase {
  Purchase({
    required this.price,
    this.date,
    this.location,
  });

  final double price;
  final DateTime? date;
  final String? location;

  Map<String, dynamic> get asMap => {
        "price": price.toString(),
        "date": date?.toIso8601String(),
        "location": location,
      };
}
