import 'package:flutter/material.dart';

class AssetCategory {
  const AssetCategory({
    required this.name,
    this.icon,
  });

  final String name;
  final IconData? icon;
}

enum DefaultCategories {
  electronics(
    category: AssetCategory(icon: Icons.devices, name: "Electronics"),
  ),
  furniture(
    category: AssetCategory(icon: Icons.weekend, name: "Furniture"),
  ),
  appliance(
    category: AssetCategory(icon: Icons.kitchen, name: "Appliances"),
  ),
  clothing(
    category: AssetCategory(icon: Icons.checkroom, name: "Clothing"),
  ),
  jewelry(
    category: AssetCategory(icon: Icons.diamond, name: "Jewelry"),
  ),
  tools(
    category: AssetCategory(icon: Icons.build, name: "Tools"),
  ),
  books(
    category: AssetCategory(icon: Icons.book, name: "Books"),
  ),
  toys(
    category: AssetCategory(icon: Icons.toys, name: "Toys"),
  ),
  vehicle(
    category: AssetCategory(icon: Icons.directions_car, name: "Vehicles"),
  ),
  sports(
    category:
        AssetCategory(icon: Icons.sports_soccer, name: "Sports Equipment"),
  ),
  art(
    category: AssetCategory(icon: Icons.brush, name: "Art"),
  ),
  music(
    category:
        AssetCategory(icon: Icons.music_note, name: "Musical Instruments"),
  ),
  office(
    category: AssetCategory(icon: Icons.work, name: "Office Supplies"),
  ),
  kitchen(
    category: AssetCategory(icon: Icons.restaurant, name: "Kitchenware"),
  ),
  garden(
    category: AssetCategory(icon: Icons.grass, name: "Garden Equipment"),
  ),
  fixture(
    category: AssetCategory(icon: Icons.light, name: "House Fixtures"),
  ),
  pets(category: AssetCategory(icon: Icons.pets, name: "Pet Supplies"));

  final AssetCategory category;

  const DefaultCategories({
    required this.category,
  });
}

// enum AssetCategory {
//   electronics(icon: Icons.devices, name: "Electronics"),
//   furniture(icon: Icons.weekend, name: "Furniture"),
//   appliance(icon: Icons.kitchen, name: "Appliances"),
//   clothing(icon: Icons.checkroom, name: "Clothing"),
//   jewelry(icon: Icons.diamond, name: "Jewelry"),
//   tools(icon: Icons.build, name: "Tools"),
//   books(icon: Icons.book, name: "Books"),
//   toys(icon: Icons.toys, name: "Toys"),
//   vehicle(icon: Icons.directions_car, name: "Vehicles"),
//   sports(icon: Icons.sports_soccer, name: "Sports Equipment"),
//   art(icon: Icons.brush, name: "Art"),
//   music(icon: Icons.music_note, name: "Musical Instruments"),
//   office(icon: Icons.work, name: "Office Supplies"),
//   kitchen(icon: Icons.restaurant, name: "Kitchenware"),
//   garden(icon: Icons.grass, name: "Garden Equipment"),
//   fixture(icon: Icons.light, name: "House Fixtures"),
//   pets(icon: Icons.pets, name: "Pet Supplies");

//   final IconData icon;
//   final String name;

//   const AssetCategory({
//     required this.icon,
//     required this.name,
//   });
// }
