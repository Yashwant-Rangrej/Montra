import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/budget_entity.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/budgets_provider.dart';
class AddBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? budgetToEdit;

  const AddBudgetScreen({super.key, this.budgetToEdit});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  int? _selectedCategoryId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCustomRange = false;

  @override
  void initState() {
    super.initState();
    if (widget.budgetToEdit != null) {
      _amount = widget.budgetToEdit!.amount;
      _selectedCategoryId = widget.budgetToEdit!.categoryId;
      _selectedMonth = widget.budgetToEdit!.month;
      _selectedYear = widget.budgetToEdit!.year;
      _startDate = widget.budgetToEdit!.startDate;
      _endDate = widget.budgetToEdit!.endDate;
      if (_startDate != null && _endDate != null) {
        _isCustomRange = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.budgetToEdit == null ? 'Add Budget' : 'Edit Budget')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _amount > 0 ? _amount.toStringAsFixed(2) : '',
                decoration: const InputDecoration(labelText: 'Budget Amount (₹)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(labelText: 'Category (Optional)'),
                    initialValue: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Overall (All Categories)')),
                      ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    ],
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading categories: $e'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<bool>(
                decoration: const InputDecoration(labelText: 'Calculation Period'),
                value: _isCustomRange,
                items: const [
                  DropdownMenuItem(value: false, child: Text('This Month')),
                  DropdownMenuItem(value: true, child: Text('Custom Date Range')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _isCustomRange = val;
                      if (!val) {
                        _startDate = null;
                        _endDate = null;
                      }
                    });
                  }
                },
              ),
              if (_isCustomRange) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Start Date'),
                          child: Text(_startDate != null ? DateFormat.yMMMd().format(_startDate!) : 'Select Date'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'End Date'),
                          child: Text(_endDate != null ? DateFormat.yMMMd().format(_endDate!) : 'Select Date'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                      if (_isCustomRange && (_startDate == null || _endDate == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both start and end dates')));
                        return;
                      }
                      
                      final budget = BudgetEntity(
                        id: widget.budgetToEdit?.id ?? 0,
                        amount: _amount,
                        month: _selectedMonth,
                        year: _selectedYear,
                        categoryId: _selectedCategoryId,
                        startDate: _isCustomRange ? _startDate : null,
                        endDate: _isCustomRange ? _endDate : null,
                      );
                      
                      if (widget.budgetToEdit == null) {
                        await ref.read(budgetRepositoryProvider).insertBudget(budget);
                      } else {
                        await ref.read(budgetRepositoryProvider).updateBudget(budget);
                      }
                      
                      ref.invalidate(budgetsProvider); // budgetsProgressProvider watches budgetsProvider
                      
                      if (context.mounted) context.pop();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Save Budget'),
                  ),
                ),
              ),
              if (widget.budgetToEdit != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await ref.read(budgetRepositoryProvider).deleteBudget(widget.budgetToEdit!.id);
                    ref.invalidate(budgetsProvider);
                    if (context.mounted) context.pop();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete Budget'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
