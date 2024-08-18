class Purchase {
  Purchase({
    this.price,
    this.date,
    this.location,
  });

  double? price;
  DateTime? date;
  String? location;

  Map<String, dynamic> get asMap => {
        "price": price.toString(),
        "date": date?.toIso8601String(),
        "location": location,
      };
}
