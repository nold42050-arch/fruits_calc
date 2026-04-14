import 'package:flutter/material.dart';
import '../models/bill_item.dart';

class SummaryScreen extends StatelessWidget {
  final List<BillItem> billItems;
  final VoidCallback onNewBill;

  const SummaryScreen({
    super.key,
    required this.billItems,
    required this.onNewBill,
  });

  double get grandTotal =>
      billItems.fold(0, (sum, item) => sum + item.subtotal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Summary'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // -- Grand Total Card --
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${billItems.length} item${billItems.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -- Items Header --
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Itemized Bill',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Swipe to see details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          // -- Item List --
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: billItems.length,
              itemBuilder: (context, index) {
                final item = billItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Index badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.fruit.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantityInGrams.toStringAsFixed(0)}g  ×  ₹${item.fruit.pricePerKg.toStringAsFixed(0)}/kg',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Subtotal
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${item.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // -- Divider + Total Row --
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),

          // -- New Bill Button --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  onNewBill();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text(
                  'New Bill',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
