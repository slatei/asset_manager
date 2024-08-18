import 'package:asset_store/models/asset/category.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatefulWidget {
  final Function(DefaultCategories? category) onChanged;

  const CategoryDropdown({
    required this.onChanged,
    super.key,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  DefaultCategories? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DefaultCategories>(
      value: _selectedCategory,
      decoration: InputDecoration(
        prefixIcon: _selectedCategory != null
            ? Icon(_selectedCategory?.category.icon)
            : const Icon(Icons.category_rounded),
        labelText: 'Category',
        border: const OutlineInputBorder(),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      // onChanged: widget.onChanged,
      onChanged: (DefaultCategories? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
        widget.onChanged(newValue);
      },
      items: DefaultCategories.values.map((DefaultCategories category) {
        return DropdownMenuItem<DefaultCategories>(
          value: category,
          child: Row(
            children: [
              if (category.category.icon != null) Icon(category.category.icon),
              const SizedBox(width: 8),
              Text(category.category.name),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (BuildContext context) {
        return DefaultCategories.values.map((DefaultCategories category) {
          return Text(category.category.name);
        }).toList();
      },
    );
  }
}
