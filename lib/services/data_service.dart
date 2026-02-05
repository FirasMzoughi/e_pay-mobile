import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'language_service.dart';

class DataService {
  final _supabase = Supabase.instance.client;

  // Helper to get current language code (e.g., 'en', 'fr')
  String get _currentLang => LanguageService().localeNotifier.value.languageCode;

  Future<List<Category>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select()
        .order('created_at', ascending: true);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Category.fromJson(json, _currentLang)).toList();
  }

  Future<List<Product>> getProducts({String? categoryId}) async {
    // Use dynamic to allow changing from FilterBuilder to TransformBuilder
    dynamic query = _supabase
        .from('products')
        .select('*, product_offers(*)');

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    
    // Order by creation for consistent list
    query = query.order('created_at', ascending: true);

    final response = await query;
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json, _currentLang)).toList();
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _supabase
        .from('payment_methods')
        .select()
        .eq('is_enabled', true)
        .order('created_at');

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => PaymentMethod.fromJson(json)).toList();
  }
}
