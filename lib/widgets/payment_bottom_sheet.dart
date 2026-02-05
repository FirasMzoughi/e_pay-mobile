import 'package:flutter/material.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/screens/chat_screen.dart';
import 'package:e_pay/services/data_service.dart';
import 'package:e_pay/services/transaction_service.dart';
import 'package:e_pay/models/models.dart';
import 'package:gap/gap.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Product product;
  final Offer offer;

  const PaymentBottomSheet({
    Key? key,
    required this.product,
    required this.offer,
  }) : super(key: key);

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final DataService _dataService = DataService();
  final TransactionService _transactionService = TransactionService();
  late Future<List<PaymentMethod>> _paymentMethodsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentMethodsFuture = _dataService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Payment Method",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textGray),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Gap(24),
          
          if (_isLoading)
             const Center(child: CircularProgressIndicator())
          else
            FutureBuilder<List<PaymentMethod>>(
              future: _paymentMethodsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No payment methods available"));
                }

                final methods = snapshot.data!;
                
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: methods.length,
                  separatorBuilder: (context, index) => const Gap(16),
                  itemBuilder: (context, index) {
                    final method = methods[index];
                    return _buildPaymentOption(
                      context,
                      name: method.name,
                      imageUrl: method.imageUrl,
                      color: Colors.blueAccent,
                      onTap: () => _handlePaymentSelection(context, method.name),
                    );
                  },
                );
              },
            ),
          
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String name,
    required String imageUrl,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      tileColor: Colors.white.withOpacity(0.05),
      leading: Container(
        padding: const EdgeInsets.all(10),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: imageUrl.isNotEmpty 
            ? Image.network(imageUrl, errorBuilder: (_,__,___) => Icon(Icons.payment, color: color))
            : Icon(Icons.payment, color: color),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
    );
  }

  Future<void> _handlePaymentSelection(BuildContext context, String method) async {
    print("DEBUG: Starting payment selection for $method");
    setState(() => _isLoading = true);
    
    // Capture the navigator BEFORE the async call
    final navigator = Navigator.of(context);

    try {
      // 1. Create Transaction
      print("DEBUG: Creating transaction...");
      final transaction = await _transactionService.createTransaction(
        productName: widget.product.name,
        offerName: widget.offer.name,
        price: widget.offer.price,
        paymentMethod: method,
      );
      print("DEBUG: Transaction created: $transaction");

      // 2. Navigate to Chat using captured navigator
      print("DEBUG: Navigating to chat...");
      
      // Close bottom sheet
      navigator.pop(); 
      
      // Navigate to Chat
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            paymentMethod: method,
            transactionDetails: transaction,
          ),
        ),
      );
      print("DEBUG: Navigation complete");

    } catch (e) {
      print("DEBUG: Error in _handlePaymentSelection: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e")),
        );
      }
    }
  }
}
