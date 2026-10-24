import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SellerScreen extends StatelessWidget {
  const SellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Operations Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seller Profile Card (Article 13 & 19)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                  child: const Text('AT', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('AetherTraderPro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 6),
                          Icon(Icons.verified, color: AppTheme.accent, size: 16),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text('PRO_SELLER • Rating 4.92 (142 orders)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payout Status (Article 13 & 16.4)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payout Balance (Licensed PSP)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                const Text('\$1,240.50 USD', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.accent)),
                const SizedBox(height: 4),
                const Text('Funds transferred directly via external PSP partner.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Request Payout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
