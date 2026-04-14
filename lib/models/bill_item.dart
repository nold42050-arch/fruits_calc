import 'fruit.dart';

class BillItem {
  final Fruit fruit;
  final double quantityInGrams;

  BillItem({required this.fruit, required this.quantityInGrams});

  double get subtotal => (fruit.pricePerKg / 1000) * quantityInGrams;
}
