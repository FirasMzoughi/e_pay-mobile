import 'package:supabase_flutter/supabase_flutter.dart';


class TransactionService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createTransaction({
    required String productName,
    required String offerName,
    required double price,
    required String paymentMethod,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('transactions')
        .insert({
          'user_id': userId,
          'product_name': productName,
          'offer_name': offerName,
          'price': price,
          'payment_method': paymentMethod,
          'status': 'pending',
        })
        .select()
        .single()
        .timeout(const Duration(seconds: 10)); // Force timeout after 10s
    
    print("Transaction created successfully: $response");
    return response;
    

  }
}
