import 'package:flutter/material.dart';

class CategoryIconHelper {
  CategoryIconHelper._();

  static IconData getIcon(String? categoryName) {
    if (categoryName == null) return Icons.shopping_bag;
    final name = categoryName.toLowerCase();
    if (name.contains('food') || name.contains('dining') || name.contains('restaurant')) {
      return Icons.restaurant;
    }
    if (name.contains('transport') ||
        name.contains('travel') ||
        name.contains('auto') ||
        name.contains('gas') ||
        name.contains('fuel')) {
      return Icons.directions_car;
    }
    if (name.contains('shop') ||
        name.contains('grocery') ||
        name.contains('market') ||
        name.contains('store')) {
      return Icons.shopping_cart;
    }
    if (name.contains('health') ||
        name.contains('medical') ||
        name.contains('pharmacy') ||
        name.contains('doctor')) {
      return Icons.local_hospital;
    }
    if (name.contains('bill') ||
        name.contains('utility') ||
        name.contains('water') ||
        name.contains('electric') ||
        name.contains('internet')) {
      return Icons.receipt_long;
    }
    if (name.contains('enter') || name.contains('movie') || name.contains('game')) {
      return Icons.movie;
    }
    if (name.contains('educat') || name.contains('school') || name.contains('book')) {
      return Icons.school;
    }
    if (name.contains('home') || name.contains('rent')) {
      return Icons.home;
    }
    if (name.contains('salary') || name.contains('income') || name.contains('wage')) {
      return Icons.attach_money;
    }
    if (name.contains('gift') || name.contains('donate')) {
      return Icons.card_giftcard;
    }
    if (name.contains('sport') || name.contains('gym')) {
      return Icons.fitness_center;
    }
    if (name.contains('subscrip')) {
      return Icons.subscriptions;
    }
    return Icons.category;
  }
}
