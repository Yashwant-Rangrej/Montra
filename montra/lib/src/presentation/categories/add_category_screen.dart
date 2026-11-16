import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/category_entity.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';
import '../../core/utils/category_icon_helper.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final CategoryEntity? categoryToEdit;

  const AddCategoryScreen({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  String _name = '';
  String _type = 'Expense';
  String _selectedIcon = 'shopping_cart';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _name = widget.categoryToEdit!.name;
      _type = widget.categoryToEdit!.type;
      _selectedIcon = widget.categoryToEdit!.icon ?? 'category';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableIcons = CategoryIconHelper.availableIcons;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filteredIcons = availableIcons.entries.where((entry) {
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();
      final iconName = entry.key.toLowerCase().replaceAll('_', ' ');
      return iconName.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryToEdit == null ? 'Add Category' : 'Edit Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Preview Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        child: Icon(
                          availableIcons[_selectedIcon] ?? Icons.category,
                          size: 38,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose Category Icon',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Groceries, Gym, Internet',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val!.trim(),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Icons (${availableIcons.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      '${filteredIcons.length} matches',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Box for Quick Filtering
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search icons (e.g. food, car, gym, bike)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 12),

              // Scrollable Icon Container
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: filteredIcons.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No matching icons found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: filteredIcons.map((entry) {
                              final isSelected = _selectedIcon == entry.key;
                              return Tooltip(
                                message: entry.key.replaceAll('_', ' '),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIcon = entry.key;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor
                                          : Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryColor
                                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: primaryColor.withValues(alpha: 0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Icon(
                                      entry.value,
                                      size: 24,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final newCat = CategoryEntity(
                        id: widget.categoryToEdit?.id ?? 0,
                        name: _name,
                        type: _type,
                        color: widget.categoryToEdit?.color ?? '#4CAF50',
                        icon: _selectedIcon,
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
                  child: Text(
                    widget.categoryToEdit == null ? 'Save Category' : 'Update Category',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
