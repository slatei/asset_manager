import 'dart:async';
import 'dart:io';
import 'package:asset_store/state/categories_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:asset_store/models/asset_orig.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssetForm extends StatefulWidget {
  final FutureOr<void> Function(AssetOriginal asset,
      {File? imageFile, Uint8List? imageBytes}) addAsset;
  final ImagePicker imagePicker;

  const AssetForm(
      {required this.addAsset, required this.imagePicker, super.key});

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');
  final _labelsController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageUrl;

  String? _name;
  String? _category;
  DateTime? _purchaseDate;
  double? _cost;
  List<String> _labels = [];

  final invalidCategorySymbols = RegExp(r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+='
      "'"
      ']');

  @override
  void initState() {
    super.initState();
    final categoriesState =
        Provider.of<CategoriesState>(context, listen: false);
    categoriesState.fetchCategories();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await widget.imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageUrl = pickedFile.path;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final asset = AssetOriginal(
        name: _name!,
        category: _category!,
        purchaseDate: _purchaseDate?.toIso8601String(),
        cost: _cost!,
        labels: _labels,
      );

      if (kIsWeb) {
        await widget.addAsset(asset, imageBytes: _imageBytes);
      } else {
        await widget.addAsset(asset, imageFile: _imageFile);
      }

      setState(() {
        _imageFile = null;
        _imageBytes = null;
        _imageUrl = null;
        _labels = [];
        _category = null;
        _purchaseDate = null;
      });
      _formKey.currentState?.reset();
    }
  }

  void _addLabel() {
    final String label = _labelsController.text.trim();
    if (label.isNotEmpty && !_labels.contains(label)) {
      setState(() {
        _labels.add(label);
        _labelsController.clear();
      });
    }
  }

  void _removeLabel(String label) {
    setState(() {
      _labels.remove(label);
    });
  }

  void _addNewCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newCategory = '';
        String errorMessage = '';
        return StatefulBuilder(
          builder: (context, setState) {
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
                          errorMessage =
                              'Category "$newCategory" already exists';
                        });
                      } else if (newCategory.contains(invalidCategorySymbols)) {
                        setState(() {
                          errorMessage =
                              'Category can not contain special characters';
                        });
                      } else {
                        await categoriesState.addCategory(newCategory);
                        if (context.mounted) {
                          setState(() {
                            _category = newCategory;
                          });
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Name',
                  icon: Icon(
                    Icons.description,
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                _name = value;
              },
            ),
            Consumer<CategoriesState>(
                builder: (context, categoriesState, child) {
              final uniqueCategories =
                  categoriesState.categories.toSet().toList();

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  icon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                // Ensures long categories don't overflow the displayed text box
                isExpanded: true,
                value: _category,
                items: [
                  ...uniqueCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        // Truncate long categories
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
                    _addNewCategory(context);
                  } else {
                    setState(() {
                      _category = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _category = value;
                },
              );
            }),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                    labelText: _purchaseDate == null
                        ? 'Select a date'
                        : DateFormat.yMMMd().format(_purchaseDate!),
                  ),
                  validator: (value) {
                    return null; // No validation for optional field
                  },
                  onSaved: (value) {
                    // No action needed as _purchaseDate is set directly by _selectDate
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _labelsController,
              decoration: InputDecoration(
                labelText: 'Add Labels',
                icon: const Icon(Icons.label),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addLabel,
                ),
              ),
              onFieldSubmitted: (_) => _addLabel(),
            ),
            const SizedBox(height: 20),
            _labels.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        children: _labels
                            .map((label) => Chip(
                                  label: Text(label),
                                  onDeleted: () => _removeLabel(label),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : const SizedBox.shrink(),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Cost',
                  icon: Icon(
                    Icons.attach_money,
                  )),
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
                _cost = double.parse(value!);
              },
            ),
            const SizedBox(height: 20),
            if (_imageFile != null || _imageUrl != null)
              kIsWeb
                  ? Image.network(_imageUrl!, height: 200)
                  : Image.file(_imageFile!, height: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Asset'),
            ),
          ]),
        ),
      ),
    );
  }
}
