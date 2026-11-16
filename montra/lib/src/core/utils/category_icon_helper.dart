import 'package:flutter/material.dart';

class CategoryIconHelper {
  CategoryIconHelper._();

  static const Map<String, IconData> availableIcons = {
    // Food & Dining
    'restaurant': Icons.restaurant,
    'fastfood': Icons.fastfood,
    'local_cafe': Icons.local_cafe,
    'coffee': Icons.coffee,
    'local_pizza': Icons.local_pizza,
    'lunch_dining': Icons.lunch_dining,
    'bakery_dining': Icons.bakery_dining,
    'icecream': Icons.icecream,
    'local_bar': Icons.local_bar,
    'liquor': Icons.liquor,

    // Groceries & Daily Needs
    'local_grocery_store': Icons.local_grocery_store,
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'shopping_basket': Icons.shopping_basket,
    'storefront': Icons.storefront,

    // Shopping, Fashion & Personal Care
    'checkroom': Icons.checkroom,
    'watch': Icons.watch,
    'diamond': Icons.diamond,
    'spa': Icons.spa,
    'face': Icons.face,
    'brush': Icons.brush,

    // Transport & Travel
    'directions_car': Icons.directions_car,
    'two_wheeler': Icons.two_wheeler,
    'pedal_bike': Icons.pedal_bike,
    'local_taxi': Icons.local_taxi,
    'directions_bus': Icons.directions_bus,
    'train': Icons.train,
    'flight': Icons.flight,
    'airplane_ticket': Icons.airplane_ticket,
    'hotel': Icons.hotel,
    'beach_access': Icons.beach_access,
    'local_gas_station': Icons.local_gas_station,
    'ev_station': Icons.ev_station,
    'car_repair': Icons.car_repair,
    'commute': Icons.commute,
    'local_shipping': Icons.local_shipping,
    'navigation': Icons.navigation,

    // Home, Utilities & Bills
    'home': Icons.home,
    'roofing': Icons.roofing,
    'receipt_long': Icons.receipt_long,
    'receipt': Icons.receipt,
    'bolt': Icons.bolt,
    'lightbulb': Icons.lightbulb,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,
    'phone_android': Icons.phone_android,
    'tv': Icons.tv,
    'solar_power': Icons.solar_power,
    'cleaning_services': Icons.cleaning_services,
    'plumbing': Icons.plumbing,
    'build': Icons.build,
    'kitchen': Icons.kitchen,
    'security': Icons.security,

    // Health, Wellness & Sports
    'local_hospital': Icons.local_hospital,
    'medical_services': Icons.medical_services,
    'medication': Icons.medication,
    'healing': Icons.healing,
    'favorite': Icons.favorite,
    'fitness_center': Icons.fitness_center,
    'sports_tennis': Icons.sports_tennis,
    'sports_soccer': Icons.sports_soccer,
    'sports_cricket': Icons.sports_cricket,
    'pool': Icons.pool,

    // Entertainment, Games & Hobbies
    'movie': Icons.movie,
    'theater_comedy': Icons.theater_comedy,
    'sports_esports': Icons.sports_esports,
    'videogame_asset': Icons.videogame_asset,
    'music_note': Icons.music_note,
    'camera_alt': Icons.camera_alt,
    'celebration': Icons.celebration,
    'attractions': Icons.attractions,

    // Family, Kids & Pets
    'child_care': Icons.child_care,
    'toys': Icons.toys,
    'pets': Icons.pets,
    'diversity_3': Icons.diversity_3,
    'elderly': Icons.elderly,

    // Education, Work & Tech
    'school': Icons.school,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'smartphone': Icons.smartphone,
    'headphones': Icons.headphones,
    'print': Icons.print,
    'cloud': Icons.cloud,

    // Finance, Investments & Donations
    'currency_rupee': Icons.currency_rupee,
    'attach_money': Icons.attach_money,
    'monetization_on': Icons.monetization_on,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,
    'credit_card': Icons.credit_card,
    'trending_up': Icons.trending_up,
    'swap_horiz': Icons.swap_horiz,
    'card_giftcard': Icons.card_giftcard,
    'volunteer_activism': Icons.volunteer_activism,
    'gavel': Icons.gavel,
    'subscriptions': Icons.subscriptions,
    'auto_awesome': Icons.auto_awesome,
    'category': Icons.category,
  };

  static IconData getIcon(String? categoryName, [String? iconName]) {
    if (iconName != null && availableIcons.containsKey(iconName)) {
      return availableIcons[iconName]!;
    }

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
    if (name.contains('transfer')) {
      return Icons.swap_horiz;
    }
    return Icons.category;
  }
}
