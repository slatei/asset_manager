import 'package:flutter/material.dart';

class AssetRoom {
  const AssetRoom({
    required this.name,
    this.icon,
  });

  final String name;
  final IconData? icon;
}

enum DefaultRooms {
  living(room: AssetRoom(icon: Icons.tv, name: "Living Room")),
  kitchen(room: AssetRoom(icon: Icons.kitchen, name: "Kitchen")),
  bedroom(room: AssetRoom(icon: Icons.bed, name: "Bedroom")),
  bathroom(room: AssetRoom(icon: Icons.bathtub, name: "Bathroom")),
  dining(room: AssetRoom(icon: Icons.restaurant, name: "Dining Room")),
  office(room: AssetRoom(icon: Icons.work, name: "Office")),
  garage(room: AssetRoom(icon: Icons.garage, name: "Garage")),
  garden(room: AssetRoom(icon: Icons.grass, name: "Garden")),
  laundry(room: AssetRoom(icon: Icons.local_laundry_service, name: "Laundry")),
  attic(room: AssetRoom(icon: Icons.roofing, name: "Attic")),
  basement(room: AssetRoom(icon: Icons.foundation, name: "Basement")),
  hallway(room: AssetRoom(icon: Icons.holiday_village, name: "Hallway")),
  closet(room: AssetRoom(icon: Icons.inventory, name: "Closet")),
  balcony(room: AssetRoom(icon: Icons.balcony, name: "Balcony")),
  patio(room: AssetRoom(icon: Icons.deck, name: "Patio"));

  final AssetRoom room;

  const DefaultRooms({required this.room});
}
