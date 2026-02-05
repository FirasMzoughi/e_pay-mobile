import 'package:flutter/material.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/widgets/glass_container.dart';
import 'package:e_pay/widgets/custom_buttons.dart';
import 'package:gap/gap.dart';

class ChatScreen extends StatelessWidget {
  final String paymentMethod;

  const ChatScreen({Key? key, required this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
             // Status Card
             Container(
               margin: const EdgeInsets.all(20),
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.amber.withOpacity(0.1),
                 border: Border.all(color: Colors.amber),
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: const [
                   Icon(Icons.hourglass_empty, color: Colors.amber),
                   Gap(10),
                   Text(
                     "Status: Pending Verification",
                     style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                   ),
                 ],
               ),
             ),
             
             Expanded(
               child: Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.receipt_long, size: 80, color: Colors.white24),
                     Gap(16),
                     Text(
                       "Pay with $paymentMethod",
                       style: const TextStyle(fontSize: 18, color: AppColors.textDark),
                     ),
                     const Gap(8),
                     const Text(
                       "Please upload the payment receipt screenshot.",
                       textAlign: TextAlign.center,
                       style: TextStyle(color: AppColors.textGray),
                     ),
                   ],
                 ),
               ),
             ),

             // Upload Area
             GlassContainer(
               margin: const EdgeInsets.all(24),
               padding: const EdgeInsets.all(24),
               child: Column(
                 children: [
                   Container(
                     height: 150,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       border: Border.all(color: AppColors.accent, style: BorderStyle.solid),
                       borderRadius: BorderRadius.circular(16),
                       color: AppColors.accent.withOpacity(0.05),
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: const [
                         Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.accent),
                         Gap(10),
                         Text("Tap to upload Screenshot", style: TextStyle(color: AppColors.accent)),
                       ],
                     ),
                   ),
                   const Gap(24),
                   GlowingButton(
                     text: "Confirm Transaction",
                     onPressed: () {
                       // Show success dialog or snackbar
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Receipt uploaded! We will verify shortly.")),
                       );
                     },
                   ),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
}
