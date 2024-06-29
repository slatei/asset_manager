import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asset_store/state/categories_state.dart';

class AssetFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String?) onNameSaved;
  final Function(String?) onCategorySaved;
  final Function(String?) onPurchaseDateSaved;
  final Function(double?) onCostSaved;
  final String? selectedCategory;
  final Function(BuildContext) onAddNewCategory;

  const AssetFormFields({
    required this.formKey,
    required this.onNameSaved,
    required this.onCategorySaved,
    required this.onPurchaseDateSaved,
    required this.onCostSaved,
    required this.selectedCategory,
    required this.onAddNewCategory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onSaved: onNameSaved,
          ),
          Consumer<CategoriesState>(
            builder: (context, categoriesState, child) {
              final uniqueCategories =
                  categoriesState.categories.toSet().toList();

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                isExpanded: true,
                value: selectedCategory,
                items: [
                  ...uniqueCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Divider(),
                  ),
                  DropdownMenuItem<String>(
                    value: 'add_new_category',
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Category',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'add_new_category') {
                    onAddNewCategory(context);
                  } else {
                    onCategorySaved(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              );
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Purchase Date'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a purchase date';
              }
              return null;
            },
            onSaved: onPurchaseDateSaved,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Cost'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a cost';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              onCostSaved(double.tryParse(value!));
            },
          ),
        ],
      ),
    );
  }
}
