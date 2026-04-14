import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fruit.dart';
import '../services/fruit_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<Box<Fruit>> _boxFuture;

  @override
  void initState() {
    super.initState();
    _boxFuture = FruitService.getBox();
  }

  void _showAddEditDialog({Fruit? fruit}) {
    final nameController = TextEditingController(text: fruit?.name ?? '');
    final priceController = TextEditingController(
      text: fruit != null ? fruit.pricePerKg.toStringAsFixed(0) : '',
    );
    final isEditing = fruit != null;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isEditing ? Icons.edit_rounded : Icons.add_circle_rounded,
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 10),
            Text(isEditing ? 'Edit Fruit' : 'Add New Fruit'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Fruit Name',
                  hintText: 'e.g. Apple, Mango',
                  prefixIcon: const Icon(Icons.local_florist_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.green.shade50,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a fruit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Price per Kg (₹)',
                  hintText: 'e.g. 200',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.green.shade50,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(val);
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameController.text.trim();
              final price = double.parse(priceController.text.trim());

              if (isEditing) {
                fruit.name = name;
                fruit.pricePerKg = price;
                await FruitService.updateFruit(fruit);
              } else {
                await FruitService.addFruit(
                    Fruit(name: name, pricePerKg: price));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            icon: Icon(isEditing ? Icons.check : Icons.add),
            label: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Fruit fruit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Delete Fruit'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${fruit.name}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await FruitService.deleteFruit(fruit);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Box<Fruit>>(
        future: _boxFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder(
            valueListenable: snapshot.data!.listenable(),
            builder: (context, Box<Fruit> box, _) {
              if (box.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_rounded,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          'No fruits added yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first fruit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final fruits = box.values.toList();

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: fruits.length,
                itemBuilder: (context, index) {
                  final fruit = fruits[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.green.shade100),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: Text(
                            fruit.name[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          fruit.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text(
                          '₹${fruit.pricePerKg.toStringAsFixed(2)} / kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_rounded,
                                  color: Colors.blue.shade400),
                              onPressed: () =>
                                  _showAddEditDialog(fruit: fruit),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: Colors.red.shade400),
                              onPressed: () => _confirmDelete(fruit),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Fruit'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
    );
  }
}
