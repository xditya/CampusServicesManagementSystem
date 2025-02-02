import 'package:flutter/material.dart';

class VendingItem {
  final String id;
  final String name;
  final double price;
  final IconData icon;

  const VendingItem({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });
}

const List<VendingItem> vendingItems = [
  VendingItem(
    id: "1",
    name: "Parotta",
    price: 15.0,
    icon: Icons.flatware,
  ),
  VendingItem(
    id: "2",
    name: "Biriyani",
    price: 10.0,
    icon: Icons.rice_bowl,
  ),
  VendingItem(
    id: "3",
    name: "Chapatti",
    price: 25.0,
    icon: Icons.local_dining,
  ),
  VendingItem(
    id: "4",
    name: "Chicken Curry",
    price: 20.0,
    icon: Icons.restaurant,
  ),
  VendingItem(
    id: "5",
    name: "Beef Curry",
    price: 30.0,
    icon: Icons.lunch_dining,
  ),
  VendingItem(
    id: "6",
    name: "Fish Curry",
    price: 30.0,
    icon: Icons.set_meal,
  ),
  VendingItem(
    id: "7",
    name: "Veg Curry",
    price: 15.0,
    icon: Icons.eco,
  ),
  VendingItem(
    id: "8",
    name: "Meals",
    price: 50.0,
    icon: Icons.dinner_dining,
  ),
];
