class Category {
  final String id;
  final String name;
  final String icon;

  const Category({required this.id, required this.name, required this.icon});

  factory Category.fromJson(Map<String, dynamic> json, String langCode) {
    String getName() {
      final local = json['name_$langCode'] as String?;
      if (local != null && local.isNotEmpty) return local;
      return (json['name_en'] as String?) ?? '';
    }
    return Category(
      id: json['id'] as String,
      name: getName(),
      icon: (json['icon'] as String?) ?? '📦',
    );
  }
}

class Offer {
  final String id;
  final String name; 
  final double price;

  const Offer({required this.id, required this.name, required this.price});

  factory Offer.fromJson(Map<String, dynamic> json, String langCode) {
    String getName() {
      final local = json['name_$langCode'] as String?;
      if (local != null && local.isNotEmpty) return local;
      return (json['name_en'] as String?) ?? '';
    }
    return Offer(
      id: json['id'] as String,
      name: getName(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String categoryId;
  final String description;
  final double rating;
  final List<Offer> offers;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.categoryId,
    required this.description,
    this.rating = 5.0,
    this.offers = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json, String langCode) {
    var offerList = <Offer>[];
    if (json['product_offers'] != null) {
      offerList = (json['product_offers'] as List)
          .map((e) => Offer.fromJson(e, langCode))
          .toList();
    }

    String getString(String keyBase) {
      final local = json['${keyBase}_$langCode'] as String?;
      if (local != null && local.isNotEmpty) return local;
      return (json['${keyBase}_en'] as String?) ?? '';
    }

    return Product(
      id: json['id'] as String,
      name: getString('name'),
      description: getString('description'),
      imageUrl: (json['image_url'] as String?) ?? '',
      categoryId: (json['category_id'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      offers: offerList,
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isEnabled;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isEnabled,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?) ?? '',
      isEnabled: (json['is_enabled'] as bool?) ?? true,
    );
  }
}
