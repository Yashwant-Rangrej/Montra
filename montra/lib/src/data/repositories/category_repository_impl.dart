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
    final categories = await db.select(db.categories).get();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    final category = await (db.select(db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
    return category != null ? _mapToEntity(category) : null;
  }

  @override
  Future<int> insertCategory(CategoryEntity category) async {
    return await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: category.name,
        type: category.type,
        color: Value(category.color),
        icon: Value(category.icon),
      ),
    );
  }

  @override
  Future<bool> updateCategory(CategoryEntity category) async {
    return await db.update(db.categories).replace(
      CategoriesCompanion(
        id: Value(category.id),
        name: Value(category.name),
        type: Value(category.type),
        color: Value(category.color),
        icon: Value(category.icon),
      ),
    );
  }

  @override
  Future<int> deleteCategory(int id) async {
    return await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
