import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fruit.dart';
import '../models/bill_item.dart';
import '../services/fruit_service.dart';
import 'summary_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with TickerProviderStateMixin {
  List<Fruit> _fruits = [];
  final List<BillItem> _billItems = [];
  Fruit? _selectedFruit;
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFruits();
  }

  Future<void> _loadFruits() async {
    final fruits = await FruitService.getAllFruits();
    setState(() {
      _fruits = fruits;
      _isLoading = false;
      if (_selectedFruit != null &&
          !fruits.any((f) => f.key == _selectedFruit!.key)) {
        _selectedFruit = null;
      }
    });
  }

  void _addToBill() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFruit == null) return;

    final quantity = double.parse(_quantityController.text.trim());
    setState(() {
      _billItems.add(
        BillItem(fruit: _selectedFruit!, quantityInGrams: quantity),
      );
      _quantityController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _billItems.removeAt(index);
    });
  }

  double get _runningTotal =>
      _billItems.fold(0, (sum, item) => sum + item.subtotal);

  void _completeBill() {
    if (_billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Add at least one item to the bill'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          billItems: List.from(_billItems),
          onNewBill: () {
            setState(() {
              _billItems.clear();
              _quantityController.clear();
              _selectedFruit = null;
            });
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFruits();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_fruits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              Text(
                'No fruits in inventory',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Go to Settings to add fruits first',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  // Switch to settings tab
                  final scaffold = Scaffold.maybeOf(context);
                  if (scaffold != null) {
                    // Navigate parent to settings tab
                  }
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Go to Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // -- Input Section --
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.teal.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Fruit dropdown
                  DropdownButtonFormField<Fruit>(
                    initialValue: _selectedFruit,
                    decoration: InputDecoration(
                      labelText: 'Select Fruit',
                      prefixIcon: const Icon(Icons.local_grocery_store_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _fruits.map((fruit) {
                      return DropdownMenuItem(
                        value: fruit,
                        child: Text(
                          '${fruit.name}  (₹${fruit.pricePerKg.toStringAsFixed(0)}/kg)',
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFruit = val),
                    validator: (val) =>
                        val == null ? 'Please select a fruit' : null,
                  ),
                  const SizedBox(height: 14),
                  // Quantity input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Quantity (grams)',
                            hintText: 'e.g. 500',
                            prefixIcon:
                                const Icon(Icons.scale_rounded),
                            suffixText: 'g',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter quantity';
                            }
                            final qty = double.tryParse(val);
                            if (qty == null || qty <= 0) {
                              return 'Must be > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _addToBill,
                          icon: const Icon(Icons.add_shopping_cart_rounded),
                          label: const Text('Add'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // -- Bill Items List --
          if (_billItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Bill (${_billItems.length} items)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${_runningTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _billItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No items added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: _billItems.length,
                    itemBuilder: (context, index) {
                      final item = _billItems[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.delete_sweep_rounded,
                              color: Colors.red.shade400),
                        ),
                        onDismissed: (_) => _removeItem(index),
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.green.shade50,
                                  child: Text(
                                    item.fruit.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.fruit.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.quantityInGrams.toStringAsFixed(0)}g × ₹${item.fruit.pricePerKg.toStringAsFixed(0)}/kg',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${item.subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _billItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _completeBill,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                'Complete  ₹${_runningTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
