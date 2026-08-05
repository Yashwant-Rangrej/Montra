import 'package:drift/drift.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/database.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;

  CategoryRepositoryImpl(this.db);

  CategoryEntity _mapToEntity(Category category) {
    return CategoryEntity(
      id: category.id,
      name: category.name,
      type: category.type,
      color: category.color,
      icon: category.icon,
    );
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    var categories = await db.select(db.categories).get();
    
    // Seed default categories if the table is empty
    if (categories.isEmpty) {
      final defaultCategories = [
        CategoriesCompanion.insert(name: 'Food & Dining', type: 'Expense', icon: const Value('restaurant'), color: const Value('#FF5722')),
        CategoriesCompanion.insert(name: 'Transportation', type: 'Expense', icon: const Value('directions_car'), color: const Value('#2196F3')),
        CategoriesCompanion.insert(name: 'Shopping', type: 'Expense', icon: const Value('shopping_bag'), color: const Value('#E91E63')),
        CategoriesCompanion.insert(name: 'Entertainment', type: 'Expense', icon: const Value('movie'), color: const Value('#9C27B0')),
        CategoriesCompanion.insert(name: 'Groceries', type: 'Expense', icon: const Value('local_grocery_store'), color: const Value('#4CAF50')),
        CategoriesCompanion.insert(name: 'Utilities', type: 'Expense', icon: const Value('bolt'), color: const Value('#FFC107')),
        CategoriesCompanion.insert(name: 'Health', type: 'Expense', icon: const Value('favorite'), color: const Value('#F44336')),
        CategoriesCompanion.insert(name: 'Salary', type: 'Income', icon: const Value('payments'), color: const Value('#4CAF50')),
        CategoriesCompanion.insert(name: 'Investment', type: 'Income', icon: const Value('trending_up'), color: const Value('#8BC34A')),
        CategoriesCompanion.insert(name: 'Freelance', type: 'Income', icon: const Value('work'), color: const Value('#03A9F4')),
        CategoriesCompanion.insert(name: 'Transfer', type: 'Transfer', icon: const Value('swap_horiz'), color: const Value('#9E9E9E')),
      ];
      
      await db.batch((batch) {
        batch.insertAll(db.categories, defaultCategories);
      });
      
      categories = await db.select(db.categories).get();
    }
    
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(String type) async {
    final query = db.select(db.categories)..where((c) => c.type.equals(type));
    final categories = await query.get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    final query = db.select(db.categories)..where((c) => c.id.equals(id));
    final category = await query.getSingleOrNull();
    return category != null ? _mapToEntity(category) : null;
  }

  @override
  Future<int> insertCategory(CategoryEntity category) async {
    return await db.into(db.categories).insert(CategoriesCompanion.insert(
      name: category.name,
      type: category.type,
      color: Value(category.color),
      icon: Value(category.icon),
    ));
  }

  @override
  Future<bool> updateCategory(CategoryEntity category) async {
    return await db.update(db.categories).replace(CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      type: Value(category.type),
      color: Value(category.color),
      icon: Value(category.icon),
    ));
  }

  @override
  Future<int> deleteCategory(int id) async {
    return await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
