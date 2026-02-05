import 'package:flutter/material.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/screens/chat_screen.dart';
import 'package:e_pay/services/data_service.dart';
import 'package:e_pay/models/models.dart';
import 'package:gap/gap.dart';

class PaymentBottomSheet extends StatefulWidget {
  const PaymentBottomSheet({Key? key}) : super(key: key);

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final DataService _dataService = DataService();
  late Future<List<PaymentMethod>> _paymentMethodsFuture;

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
                "Select Payment Method", // Could be localized
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
                shrinkWrap: true, // Important for BottomSheet
                itemCount: methods.length,
                separatorBuilder: (context, index) => const Gap(16),
                itemBuilder: (context, index) {
                  final method = methods[index];
                  // Use a default icon or map based on name if image is URL
                  // For now assuming image URL is available or we use a placeholder icon
                  return _buildPaymentOption(
                    context,
                    name: method.name,
                    // Use network image if imageUrl is present, else default icon
                    imageUrl: method.imageUrl,
                    color: Colors.blueAccent, // Default color for dynamic items
                    onTap: () => _navigateToChat(context, method.name),
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

  void _navigateToChat(BuildContext context, String method) {
    Navigator.pop(context); // Close sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(paymentMethod: method),
      ),
    );
  }
}
