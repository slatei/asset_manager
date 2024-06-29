import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asset_store/state/categories_state.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(String) onCategoryAdded;

  const AddCategoryDialog({
    required this.onCategoryAdded,
    super.key,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  String newCategory = '';
  String errorMessage = '';

  final invalidCategorySymbols = RegExp(r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+='
      "'"
      ']');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              newCategory = value;
              setState(() {
                errorMessage = '';
              });
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (newCategory.isNotEmpty) {
              final categoriesState =
                  Provider.of<CategoriesState>(context, listen: false);

              if (categoriesState.categories.contains(newCategory)) {
                setState(() {
                  errorMessage = 'Category "$newCategory" already exists';
                });
              } else if (newCategory.contains(invalidCategorySymbols)) {
                setState(() {
                  errorMessage = 'Category can not contain special characters';
                });
              } else {
                await categoriesState.addCategory(newCategory);
                widget.onCategoryAdded(newCategory);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
