import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesState extends ChangeNotifier {
  final FirebaseFirestore firestore;

  CategoriesState({required this.firestore});

  List<String> _categories = [];

  List<String> get categories => _categories;

  Future<void> fetchCategories() async {
    final snapshot = await firestore.collection('categories').get();
    _categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    await firestore.collection('categories').add({'name': category});
    _categories.add(category);
    notifyListeners();
  }
}
