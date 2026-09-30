import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/category_entity.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final CategoryEntity? categoryToEdit;

  const AddCategoryScreen({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Expense';

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _name = widget.categoryToEdit!.name;
      _type = widget.categoryToEdit!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryToEdit == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val!.trim(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final newCat = CategoryEntity(
                        id: widget.categoryToEdit?.id ?? 0,
                        name: _name,
                        type: _type,
                        color: widget.categoryToEdit?.color ?? '#4CAF50',
                        icon: widget.categoryToEdit?.icon ?? 'category',
                      );

                      if (widget.categoryToEdit == null) {
                        await ref.read(categoryRepositoryProvider).insertCategory(newCat);
                      } else {
                        await ref.read(categoryRepositoryProvider).updateCategory(newCat);
                      }

                      ref.invalidate(categoriesProvider);
                      if (context.mounted) context.pop();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Save Category'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
