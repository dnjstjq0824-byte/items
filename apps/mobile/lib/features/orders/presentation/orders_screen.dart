import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-847291',
      'title': '5,000x Chaos Orb (Face-to-Face Trade)',
      'game': 'Path of Exile 2',
      'server': 'Standard League',
      'amount': '\$42.50',
      'status': 'DELIVERY_CLAIMED',
      'statusColor': AppTheme.accent,
      'isAwaitingBuyerConfirm': true,
      'proofHash': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    },
    {
      'id': 'ORD-719302',
      'title': '10,000,000 Gil Handover at Limsa',
      'game': 'Final Fantasy XIV',
      'server': 'Chocobo (Mana)',
      'amount': '\$32.00',
      'status': 'IN_DELIVERY',
      'statusColor': AppTheme.primary,
      'isAwaitingBuyerConfirm': false,
      'proofHash': null,
    },
    {
      'id': 'ORD-782103',
      'title': 'Lord Rune Stacks (99x Stack x 7)',
      'game': 'Elden Ring',
      'server': 'Global',
      'amount': '\$19.99',
      'status': 'COMPLETED',
      'statusColor': AppTheme.success,
      'isAwaitingBuyerConfirm': false,
      'proofHash': '9a84218eb019284fa10928410294810294810294810294810294810294810294',
    },
    {
      'id': 'ORD-659124',
      'title': 'Blessed Armor Enchant Scroll x 10',
      'game': 'Lineage W',
      'server': 'Eva 01',
      'amount': '\$145.00',
      'status': 'DISPUTED',
      'statusColor': AppTheme.danger,
      'isAwaitingBuyerConfirm': false,
      'proofHash': '4f92182048102948102948102948102948102948102948102948102948102948',
    },
  ];

  void _showConfirmReceiptDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Confirm Asset Delivery', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you received the items for order ${order['id']}?', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Text(
                '⚠️ This action will release escrow funds immediately to the seller and cannot be undone.',
                style: TextStyle(color: Colors.amber, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order['status'] = 'COMPLETED';
                order['statusColor'] = AppTheme.success;
                order['isAwaitingBuyerConfirm'] = false;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order['id']} confirmed. Escrow released to seller.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Confirm & Release', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog(Map<String, dynamic> order) {
    String selectedReason = 'NOT_RECEIVED';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          title: const Text('Open Trade Dispute', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Disputes lock escrow funds immediately for 4-Eyes operational review.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                dropdownColor: AppTheme.darkBackground,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                ),
                items: const [
                  DropdownMenuItem(value: 'NOT_RECEIVED', child: Text('Item was not handed over in-game')),
                  DropdownMenuItem(value: 'INCORRECT_QTY', child: Text('Wrong quantity or missing items')),
                  DropdownMenuItem(value: 'WRONG_SERVER', child: Text('Delivered on incorrect realm/server')),
                  DropdownMenuItem(value: 'SELLER_UNRESPONSIVE', child: Text('Seller did not appear at meet point')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedReason = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Describe in-game meet up issue...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  order['status'] = 'DISPUTED';
                  order['statusColor'] = AppTheme.danger;
                  order['isAwaitingBuyerConfirm'] = false;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dispute opened for ${order['id']}. An operations agent has been assigned.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              child: const Text('Submit Claim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders & Transactions'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, idx) {
          final order = _orders[idx];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order['id'], style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (order['statusColor'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(color: order['statusColor'], fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(order['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                const SizedBox(height: 2),
                Text('${order['game']} • ${order['server']}', style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                const SizedBox(height: 6),
                Text('Total: ${order['amount']} (Escrow Locked)', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),

                if (order['isAwaitingBuyerConfirm'] == true) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_outlined, color: AppTheme.accent, size: 16),
                            SizedBox(width: 6),
                            Text('Seller Evidence Submitted (SHA-256)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Digest: ${(order['proofHash'] as String).substring(0, 24)}...',
                          style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showDisputeDialog(order),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                            side: const BorderSide(color: AppTheme.danger),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Open Dispute', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showConfirmReceiptDialog(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Confirm Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
